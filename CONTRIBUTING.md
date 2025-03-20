# How to run test

`.github/workflows/test.yml`は実際に動いているので、これを見るのが一番わかりやすいですが、一応記しておきます。

1. [vim-themis](https://github.com/thinca/vim-themis)をcloneする
1. `themis`を`$PATH`に通す（以下の例では、`~/bin`が`$PATH`に含まれているとします）
1. テストを実行する
    - `--reporter`は自由に指定できます

```shell-session
$ git clone https://github.com/thinca/vim-themis ~/bin/vim-themis
$ themis test --reporter spec
```
