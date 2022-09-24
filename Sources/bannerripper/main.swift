import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking // Required on Linux
#endif
let argv = CommandLine.arguments
var channelUrl = ""
setbuf(stdout, nil)
setbuf(stderr, nil)
if argv.contains("-h") || argv.contains("--help") {
    print("usage: bannerripper <channel_url> <output_path>\nIf \nIf channel_url is not specified (no arguments passed), then the user will be asked to provide a channel URL.\nIf output_path is not specified, then the last path component of the URL will be used. The file extension should be jpg.")
    exit(0)
}
if argv.count < 2 {
    print("Channel URL: ", terminator: "") // Asks the user for a channel URL if none passed
    let line = readLine()
    if let line = line {
        channelUrl = line
    } else {
        print("")
        exit(0)
    }
} else {
    channelUrl = argv[1] // If a channel URL is passed, sets the channelUrl variable
}
let url = URL(string: channelUrl)
if let url = url {
    var urlreq = URLRequest(url: url)
    urlreq.addValue("bannerripper", forHTTPHeaderField: "User-Agent") // If we don't change the user agent, then we will not be able to download the channel page.
    print("Downloading channel page...")
    let session = URLSession.shared.dataTask(with: urlreq) { (data, response, error) in // Starts the download
        guard let data = data else { // Safely unwarps the data
            fputs("Failed to download channel page.\n", stderr)
            exit(-1)
        }
        let string = String(data: data, encoding: .utf8) // Converts the data to a string
        print("Processing channel page...")
        guard let string = string else { // Safely unwarps the string
            fputs("Failed to convert string to data. Perhaps the URL specified is not a YouTube channel URL.\n", stderr)
            exit(-1)
        }
        if !string.contains("tvBanner") { // If the banner is not found, then exit with an error instead of crash due to index out of range
            fputs("Could not get banner from channel. Perhaps the URL specified is not a YouTube channel URL.\n", stderr)
            exit(-1)
        }
        let stringTVBanners = string.components(separatedBy: "tvBanner")[1].components(separatedBy: "mobileBanner")[0] // Extracts the TV banner portion of the page
        let highestResUrlPart = stringTVBanners.components(separatedBy: "url\":\"").last
        guard let highestResUrlPart = highestResUrlPart else {
            fputs("Something extremely unexpected happened and the url could not be obtained.\n", stderr)
            exit(-1)
        }
        let url = URL(string: highestResUrlPart.components(separatedBy: "\"")[0]) // Gets the URL for the highest resolution TV banner
        guard let url = url else { // Safely unwarps the URL (the URL is nil for me if the User-Agent header is not set)
            fputs("Something really weird is up with the banner URL and the banner cannot be obtained.\n", stderr)
            exit(-1)
        }
        do {
            print("Downloading banner...")
            let bannerData = try Data(contentsOf: url) // Downloads the channel banner directly from YouTube
            print("Saving banner...")
            var fileName = channelUrl
            if fileName.hasSuffix("/") {
                fileName.removeLast()
            }
            fileName = fileName.components(separatedBy: "/").last ?? "unknown"
            var fileSaveLocation = FileManager.default.currentDirectoryPath + "/\(fileName).jpg"
            if argv.count > 2 {
                fileSaveLocation = argv[2]
            }
            do {
                try bannerData.write(to: URL(fileURLWithPath: fileSaveLocation)) // Writes the downloaded banner to a file
                print("Success! Banner saved to \(fileSaveLocation)")
                exit(0)
            } catch {
                fputs("Could not save banner:\n\(error)\n", stderr)
            }
        } catch {
            fputs("Could not download banner:\n\(error)\n", stderr)
        }
    }
    session.resume()
} else {
    fputs("Error: Invalid URL\n", stderr)
    exit(-1)
}
sleep(300)
fputs("Timed out\n", stderr) // If it takes over five minutes to complete, then something definitely went wrong.
exit(-1)
