import type { Denops } from "jsr:@denops/std@^7.0.0";
import * as fn from "jsr:@denops/std@^7.0.0/function";
import * as vars from "jsr:@denops/std@^7.0.0/variable";
import { ScratchBufferConfig } from "./types.ts";

// 設定を取得する関数
export async function getConfig(denops: Denops): Promise<ScratchBufferConfig> {
  const filePattern = await vars.g.get(denops, "scratch_buffer_file_pattern") as Record<string, string>;
  const autoHideBuffer = await vars.g.get(denops, "scratch_buffer_auto_hide_buffer") as Record<string, boolean>;
  
  return {
    filePattern: {
      whenTmpBuffer: filePattern.when_tmp_buffer,
      whenFileBuffer: filePattern.when_file_buffer,
    },
    defaultFileExt: await vars.g.get(denops, "scratch_buffer_default_file_ext") as string,
    defaultOpenMethod: await vars.g.get(denops, "scratch_buffer_default_open_method") as string,
    defaultBufferSize: await vars.g.get(denops, "scratch_buffer_default_buffer_size") as number,
    autoSaveFileBuffer: await vars.g.get(denops, "scratch_buffer_auto_save_file_buffer") as boolean,
    useDefaultKeymappings: await vars.g.get(denops, "scratch_buffer_use_default_keymappings") as boolean,
    autoHideBuffer: {
      whenTmpBuffer: autoHideBuffer.when_tmp_buffer,
      whenFileBuffer: autoHideBuffer.when_file_buffer,
    }
  };
}

// バッファ名から現在の最大インデックスを取得する
export async function findCurrentIndex(denops: Denops, pattern: string): Promise<number> {
  // バッファリストからインデックスを抽出
  const bufferNames = await fn.getbufinfo(denops, {}) as { name: string }[];
  const bufferIndices = bufferNames
    .map(info => extractIndexFromName(info.name, pattern))
    .filter((index): index is number => index !== null)
    .reduce((max, current) => Math.max(max, current), 0);

  // ファイルシステムからインデックスを抽出
  const globPattern = pattern.replace("%d", "*");
  const files = await denops.call("glob", globPattern, 0, 1) as string[];
  const fileIndices = files
    .map(name => extractIndexFromName(name, pattern))
    .filter((index): index is number => index !== null)
    .reduce((max, current) => Math.max(max, current), 0);

  return Math.max(bufferIndices, fileIndices);
}

// 名前からインデックスを抽出する
export function extractIndexFromName(name: string, pattern: string): number | null {
  const regex = new RegExp(pattern.replace("%d", "(\\d+)"));
  const match = name.match(regex);
  return match ? parseInt(match[1], 10) : null;
}

// ファイルパターンを取得
export function getFilePattern(config: ScratchBufferConfig, isTemp: boolean, fileExt: string): string {
  const basePattern = isTemp 
    ? config.filePattern.whenTmpBuffer 
    : config.filePattern.whenFileBuffer;
  
  return fileExt === "--no-file-ext" || fileExt === "" 
    ? basePattern 
    : `${basePattern}.${fileExt}`;
}

// バッファをワイプする補助関数
export async function wipeBuffers(denops: Denops, filePattern: string): Promise<void> {
  const scratchPrefix = "^" + filePattern.replace("%d", "");
  const bufferInfo = await fn.getbufinfo(denops, {}) as { name: string, bufnr: number }[];
  
  for (const info of bufferInfo) {
    if (new RegExp(scratchPrefix).test(info.name)) {
      await denops.cmd(`:bwipe! ${info.bufnr}`);
    }
  }
}
