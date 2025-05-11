import { autocmd, Denops } from "jsr:@denops/std@^7.0.0";
import * as DenopsTest from "./deps/test.ts";
import { main } from "./main.ts";
import { dirname, fromFileUrl, resolve } from "jsr:@std/path";

// プラグインのrootパスを取得する
const runtimepath = resolve(
  dirname(fromFileUrl(import.meta.url)),
  "../.."
);

/**
 * denops.vimプラグイン用のテストヘルパー関数
 * lambdalisue/gin.vimを参考に実装
 */
export function test(def: DenopsTest.TestDefinition): void {
  const fn = def.fn;
  DenopsTest.test({
    ...def,
    async fn(denops: Denops, t: Deno.TestContext) {
      await main(denops);
      await denops.dispatcher.initialize();
      await autocmd.emit(denops, "User", "DenopsPluginPost:scratch_buffer", {
        nomodeline: true,
      });
      await fn(denops, t);
    },
    pluginName: "scratch_buffer",
    prelude: [
      `set runtimepath^=${runtimepath}`,
      "runtime! plugin/scratch_buffer.vim",
      ...(def.prelude ?? []),
    ],
  });
}
