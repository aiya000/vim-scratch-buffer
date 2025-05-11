import { Denops } from "jsr:@denops/std@^7.0.0";
import * as fn from "jsr:@denops/std@^7.0.0/function";
import { test } from "./testutil.ts";
import { assertEquals, assertNotEquals } from "./deps/test.ts";

/**
 * コマンドインターフェイスのテスト
 */
test({
  mode: "all",
  name: "スクラッチバッファのVimコマンドインターフェース",
  async fn(denops: Denops) {
    // :ScratchTmp コマンドのテスト
    await denops.cmd("ScratchTmp");
    const tmpBufname = await fn.bufname(denops, "%") as string;
    const tmpBuftype = await fn.getbufvar(denops, "%", "&buftype") as string;
    
    assertEquals(tmpBuftype, "nofile", "ScratchTmpコマンドで作られたバッファのbuftypeはnofileであること");
    
    // :Scratch コマンドのテスト
    await denops.cmd("Scratch");
    const bufname = await fn.bufname(denops, "%") as string;
    const buftype = await fn.getbufvar(denops, "%", "&buftype") as string;
    
    assertEquals(buftype, "", "Scratchコマンドで作られたバッファのbuftypeは空であること");
    assertNotEquals(tmpBufname, bufname, "ScratchTmpとScratchで異なるバッファが作成されること");
    
    // :ScratchClean コマンドのテスト
    await denops.cmd("ScratchClean");
    
    // クリーンアップ後にバッファが残っていないことを確認
    const bufferInfo = await fn.getbufinfo(denops, {}) as { name: string, bufnr: number }[];
    const scratchBuffers = bufferInfo.filter(info => 
      info.name.includes("scratch_") && 
      (info.name.endsWith(".txt") || !info.name.includes("."))
    );
    
    assertEquals(scratchBuffers.length, 0, "ScratchCleanコマンド後にスクラッチバッファが存在しないこと");
  },
});

/**
 * オプション付きコマンドのテスト
 */
test({
  mode: "all",
  name: "オプション付きスクラッチコマンド",
  async fn(denops: Denops) {
    // カスタム拡張子でスクラッチバッファを開く
    await denops.cmd("Scratch md");
    const bufname = await fn.bufname(denops, "%") as string;
    
    // 検証
    assertEquals(bufname.endsWith(".md"), true, "指定した拡張子でバッファが作成されること");
    
    // クリーンアップ
    await denops.cmd("ScratchClean");
  },
});
