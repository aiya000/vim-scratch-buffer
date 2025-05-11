// 設定データの型定義
export interface ScratchBufferConfig {
  filePattern: {
    whenTmpBuffer: string;
    whenFileBuffer: string;
  };
  defaultFileExt: string;
  defaultOpenMethod: string;
  defaultBufferSize: number;
  autoSaveFileBuffer: boolean;
  useDefaultKeymappings: boolean;
  autoHideBuffer: {
    whenTmpBuffer: boolean;
    whenFileBuffer: boolean;
  };
}
