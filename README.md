# BannerRipper

BannerRipper downloads YouTube channel banner images straight from YouTube in the highest TV resolution (full image).

# Usage

Simple run bannerripper with the channel URL and output path (optional). If no arguments are passed, you will be prompted for the URL.

# Building

Simply chdir into the package directory and build using `make`. The release version can be build using `make release`.

# Example

To download the banner for a YouTube channel at https://www.youtube.com/c/GitHub and save the banner to a file named TestBanner.jpg, use `bannerripper https://www.youtube.com/c/GitHub TestBanner.jpg`

# Windows

To build on Windows, you have to replace the `sleep(300)` with `try? await Task.sleep(nanoseconds: 300_000_000_000)`. You should also remove `setbuf(stdout, nil)` and `setbuf(stderr, nil)`.
