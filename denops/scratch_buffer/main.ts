import type { Denops, Entrypoint } from "jsr:@denops/std@^7.0.0";
import * as fn from "jsr:@denops/std@^7.0.0/function";
import * as path from "jsr:@std/path";
import { getConfig, findCurrentIndex, getFilePattern, wipeBuffers } from "./buffer.ts";

export const main: Entrypoint = (denops) => {
  denops.dispatcher = {
    // スクラッチバッファを開く
    async open(
      isTemp: boolean, 
      openingNextFreshBuffer: boolean, 
      fileExt?: string, 
      openMethod?: string, 
      bufferSize?: number
    ) {
      const config = await getConfig(denops);
      
      // デフォルト値の設定
      fileExt = fileExt ?? config.defaultFileExt;
      openMethod = openMethod ?? config.defaultOpenMethod;
      bufferSize = bufferSize ?? config.defaultBufferSize;

      const filePattern = getFilePattern(config, isTemp, fileExt);
      
      // 次のインデックスを計算
      const index = await findCurrentIndex(denops, filePattern) + (openingNextFreshBuffer ? 1 : 0);
      const fileName = filePattern.replace("%d", index.toString());

      // バッファを開く
      await denops.cmd(`silent ${openMethod} ${fileName}`);

      // バッファタイプの設定
      if (isTemp) {
        await denops.cmd("setlocal buftype=nofile");
        await denops.cmd("setlocal bufhidden=hide");
      } else {
        await denops.cmd("setlocal buftype=");
        await denops.cmd("setlocal bufhidden=");
      }

      // バッファサイズの調整
      if (bufferSize) {
        const resizeCmd = openMethod === "vsp" ? "vertical resize" : "resize";
        await denops.cmd(`${resizeCmd} ${bufferSize}`);
      }
    },

    // 全てのスクラッチバッファとファイルをクリーンアップ
    async clean() {
      const config = await getConfig(denops);

      // 永続ファイルの削除
      const persistentFilePattern = config.filePattern.whenFileBuffer.replace("%d", "*");
      const persistentFiles = await denops.call("glob", persistentFilePattern, 0, 1) as string[];
      
      for (const file of persistentFiles) {
        try {
          await Deno.remove(file);
        } catch (e) {
          console.error(`Failed to remove file ${file}: ${e}`);
        }
      }

      // バッファのワイプ
      await wipeBuffers(denops, config.filePattern.whenTmpBuffer);
      await wipeBuffers(denops, config.filePattern.whenFileBuffer);
    },

    // 自動保存用のハンドラー
    async autoSaveFileBuffer() {
      const config = await getConfig(denops);
      
      if (config.autoSaveFileBuffer) {
        const buftype = await fn.getbufvar(denops, "%", "&buftype") as string;
        if (buftype !== "nofile") {
          await denops.cmd("silent write");
        }
      }
    },

    // 自動非表示用のハンドラー
    async autoHideBuffer() {
      const config = await getConfig(denops);
      const buftype = await fn.getbufvar(denops, "%", "&buftype") as string;

      if (buftype === "nofile" && config.autoHideBuffer.whenTmpBuffer) {
        await denops.cmd("quit");
        return;
      }

      if (config.autoHideBuffer.whenFileBuffer) {
        await denops.cmd("quit");
        return;
      }
    },

    // プラグインの初期化（設定の反映）
    async initialize() {
      const config = await getConfig(denops);
      
      // 自動コマンドの設定
      await denops.cmd(`
        augroup VimScratchBuffer
          autocmd!
          execute 'autocmd TextChanged ' . substitute('${config.filePattern.whenFileBuffer}', '%d', '*', '') . ' call denops#request("scratch_buffer", "autoSaveFileBuffer", [])'
          execute 'autocmd WinLeave ' . substitute('${config.filePattern.whenTmpBuffer}', '%d', '*', '') . ' call denops#request("scratch_buffer", "autoHideBuffer", [])'
          execute 'autocmd WinLeave ' . substitute('${config.filePattern.whenFileBuffer}', '%d', '*', '') . ' call denops#request("scratch_buffer", "autoHideBuffer", [])'
        augroup END
      `);
    },
  };
};

// バッファをワイプする補助関数
async function wipeBuffers(denops: Denops, filePattern: string): Promise<void> {
  const scratchPrefix = "^" + filePattern.replace("%d", "");
  const bufferInfo = await fn.getbufinfo(denops, {}) as { name: string, bufnr: number }[];
  
  for (const info of bufferInfo) {
    if (new RegExp(scratchPrefix).test(info.name)) {
      await denops.cmd(`:bwipe! ${info.bufnr}`);
    }
  }
}
