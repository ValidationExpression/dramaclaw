import { describe, expect, it } from "vitest";

import { isVideoFile, VIDEO_FILE_ACCEPT } from "./videoFileTypes";

describe("isVideoFile", () => {
  it("accepts standard video MIME types", () => {
    expect(isVideoFile({ type: "video/mp4", name: "clip.mp4" })).toBe(true);
    expect(isVideoFile({ type: "video/quicktime", name: "clip.mov" })).toBe(true);
  });

  it("accepts .mxf and other no-MIME containers by extension", () => {
    // 浏览器给 .mxf 的 file.type 是空串——正是要靠扩展名兜住的场景。
    expect(isVideoFile({ type: "", name: "shot001.mxf" })).toBe(true);
    expect(isVideoFile({ type: "", name: "SHOT001.MXF" })).toBe(true);
    expect(isVideoFile({ type: "", name: "raw.avi" })).toBe(true);
    expect(isVideoFile({ type: "", name: "stream.ts" })).toBe(true);
  });

  it("rejects non-video files", () => {
    expect(isVideoFile({ type: "image/png", name: "poster.png" })).toBe(false);
    expect(isVideoFile({ type: "audio/mpeg", name: "voice.mp3" })).toBe(false);
    expect(isVideoFile({ type: "", name: "notes.txt" })).toBe(false);
    // 扩展名出现在中间但结尾不是视频容器：不误判。
    expect(isVideoFile({ type: "", name: "my.mxf.txt" })).toBe(false);
  });

  it("lists the extra extensions in the <input accept> string", () => {
    expect(VIDEO_FILE_ACCEPT).toContain("video/*");
    expect(VIDEO_FILE_ACCEPT).toContain(".mxf");
  });
});
