// 视频文件识别口径的单一来源。
//
// 浏览器给 .mxf 等专业/老容器的 file.type 是空串，纯 `startsWith("video/")`
// 会把它们挡在上传门外。这里统一成「MIME 是 video/* 或扩展名在白名单里」，
// 让画布拖放（Canvas）、UploadNode morph、VideoNode 各入口口径一致；命中后
// 交给 videoTranscode.ts 的 ffmpeg 兜底把这些容器转成 H.264 mp4。

// 无（或不可靠）MIME、但 ffmpeg.wasm 能解封装的容器扩展名。
export const EXTRA_VIDEO_EXTENSIONS = /\.(mxf|mkv|avi|ts|mts|m2ts|flv|wmv|m4v|mpg|mpeg)$/i;

// <input accept> 用：video/* 覆盖有 MIME 的，逗号后逐个列出无 MIME 的扩展名。
export const VIDEO_FILE_ACCEPT =
  "video/*,.mxf,.mkv,.avi,.ts,.mts,.m2ts,.flv,.wmv,.m4v,.mpg,.mpeg";

export function isVideoFile(file: { type: string; name: string }): boolean {
  return file.type.startsWith("video/") || EXTRA_VIDEO_EXTENSIONS.test(file.name);
}
