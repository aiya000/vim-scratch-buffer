import * as fn from "jsr:@denops/std@^7.0.0/function";
import { Denops } from "jsr:@denops/std@^7.0.0";
import { test } from "./testutil.ts";
import { assertEquals, assertExists } from "./deps/test.ts";

/**
 * ディスパッチャーの初期化テスト
 */
test({
  mode: "all",
  name: "プラグインの初期化",
  async fn(denops: Denops) {
    // 初期化は既にtestutil内で行われている
    
    // 自動コマンドが正しく設定されているか確認
    const autocmds = await denops.eval('execute("autocmd VimScratchBuffer")') as string;
    
    // 検証
    assertExists(autocmds.match(/TextChanged.*scratch_/), "TextChanged自動コマンドが設定されていること");
    assertExists(autocmds.match(/WinLeave.*scratch_/), "WinLeave自動コマンドが設定されていること");
  },
});

/**
 * 自動保存機能のテスト
 */
test({
  mode: "all",
  name: "永続バッファの自動保存",
  async fn(denops: Denops, t: Deno.TestContext) {
    await t.step({
      name: "ファイルバッファでの自動保存",
      async fn() {
        // 永続バッファを開く
        await denops.dispatch("scratch_buffer", "open", false, false);
        const bufname = await fn.bufname(denops, "%") as string;
        
        // テキストを追加
        await denops.cmd('call setline(1, "テスト内容")');
        
        // autoSaveFileBufferを呼び出し
        await denops.dispatch("scratch_buffer", "autoSaveFileBuffer");
        
        // ファイルが存在するか確認
        try {
          await Deno.stat(bufname);
          // ファイルが存在する場合、成功
        } catch {
          throw new Error("ファイルが保存されていません");
        }
        
        // クリーンアップ
        await denops.cmd("bwipeout!");
        try {
          await Deno.remove(bufname);
        } catch {
          // 削除できなくても続行
        }
      },
    });
  },
});

/**
 * 自動非表示機能のテスト
 */
test({
  mode: "all",
  name: "バッファの自動非表示",
  async fn(denops: Denops) {
    // テスト用に新しいバッファを開く
    await denops.cmd("new");
    const initialBufCount = await denops.eval("winnr('$')") as number;
    
    // 一時スクラッチバッファを開く
    await denops.dispatch("scratch_buffer", "open", true, false);
    
    // もう一つウィンドウを開く
    await denops.cmd("split");
    
    // 一時スクラッチバッファに戻る
    await denops.cmd("wincmd p");
    
    // autoHideBufferを呼び出し
    await denops.dispatch("scratch_buffer", "autoHideBuffer");
    
    // ウィンドウ数が減ったか確認
    const finalBufCount = await denops.eval("winnr('$')") as number;
    
    // 検証
    assertEquals(finalBufCount, initialBufCount, "自動非表示によりウィンドウ数が元に戻ったこと");
    
    // クリーンアップ
    await denops.cmd("bwipeout!");
  },
});
