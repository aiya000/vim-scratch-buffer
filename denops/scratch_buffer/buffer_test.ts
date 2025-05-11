import * as fn from "jsr:@denops/std@^7.0.0/function";
import { Denops } from "jsr:@denops/std@^7.0.0";
import { test } from "./testutil.ts";
import { assertEquals, assertExists, assertNotEquals } from "./deps/test.ts";

/**
 * 一時的なスクラッチバッファのテスト
 */
test({
  mode: "all",
  name: "一時スクラッチバッファを開く",
  async fn(denops: Denops) {
    // 一時的なスクラッチバッファを開く
    await denops.dispatch("scratch_buffer", "open", true, false);
    
    // バッファ名とバッファタイプを確認
    const bufname = await fn.bufname(denops, "%") as string;
    const buftype = await fn.getbufvar(denops, "%", "&buftype") as string;
    
    // 検証
    assertExists(bufname.match(/scratch_\d+/), "バッファ名がscratch_[数字]の形式であること");
    assertEquals(buftype, "nofile", "一時バッファのbuftypeはnofileであること");
    
    // バッファを閉じる
    await denops.cmd("bwipeout!");
  },
});

/**
 * 永続的なスクラッチバッファのテスト
 */
test({
  mode: "all",
  name: "永続的なスクラッチファイルバッファを開く",
  async fn(denops: Denops) {
    // 永続的なスクラッチバッファを開く
    await denops.dispatch("scratch_buffer", "open", false, false);
    
    // バッファ名とバッファタイプを確認
    const bufname = await fn.bufname(denops, "%") as string;
    const buftype = await fn.getbufvar(denops, "%", "&buftype") as string;
    
    // 検証
    assertExists(bufname.match(/scratch_\d+\.txt/), "バッファ名がscratch_[数字].txtの形式であること");
    assertEquals(buftype, "", "永続バッファのbuftypeは空であること");
    
    // バッファを閉じる
    await denops.cmd("bwipeout!");
  },
});

/**
 * カスタム拡張子のスクラッチバッファのテスト
 */
test({
  mode: "all",
  name: "カスタム拡張子でスクラッチバッファを開く",
  async fn(denops: Denops) {
    // マークダウン形式のスクラッチバッファを開く
    await denops.dispatch("scratch_buffer", "open", false, false, "md");
    
    // バッファ名を確認
    const bufname = await fn.bufname(denops, "%") as string;
    
    // 検証
    assertExists(bufname.match(/scratch_\d+\.md/), "バッファ名がscratch_[数字].mdの形式であること");
    
    // バッファを閉じる
    await denops.cmd("bwipeout!");
  },
});

/**
 * 連続してバッファを開くテスト
 */
test({
  mode: "all",
  name: "連続して新しいバッファを開く",
  async fn(denops: Denops) {
    // 1つ目のバッファを開く
    await denops.dispatch("scratch_buffer", "open", true, false);
    const bufname1 = await fn.bufname(denops, "%") as string;
    
    // 2つ目のバッファを開く（新しいインデックスで）
    await denops.dispatch("scratch_buffer", "open", true, true);
    const bufname2 = await fn.bufname(denops, "%") as string;
    
    // 検証
    assertNotEquals(bufname1, bufname2, "連続して開いた2つのバッファは異なること");
    
    // バッファを閉じる
    await denops.cmd("bwipeout!");
    await denops.cmd(`bwipeout! ${bufname1}`);
  },
});

/**
 * バッファのクリーンアップテスト
 */
test({
  mode: "all",
  name: "スクラッチバッファのクリーンアップ",
  async fn(denops: Denops) {
    // いくつかのバッファを作成
    await denops.dispatch("scratch_buffer", "open", true, false);
    await denops.dispatch("scratch_buffer", "open", false, true);
    
    // クリーンアップを実行
    await denops.dispatch("scratch_buffer", "clean");
    
    // バッファ一覧を取得
    const bufferInfo = await fn.getbufinfo(denops, {}) as { name: string, bufnr: number }[];
    const scratchBuffers = bufferInfo.filter(info => 
      info.name.includes("scratch_") && 
      (info.name.endsWith(".txt") || !info.name.includes("."))
    );
    
    // 検証
    assertEquals(scratchBuffers.length, 0, "すべてのスクラッチバッファが削除されていること");
  },
});
