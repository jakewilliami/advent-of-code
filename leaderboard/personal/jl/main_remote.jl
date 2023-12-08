using DotEnv, JSON, HTTP, Base64, TranscodingStreams#, Libz, CodecZlib

function _get_leaderboard(url::S) where {S <: AbstractString}
    r = HTTP.request("GET", url,
        [
            "Host" => "adventofcode.com",
            "Sec-Ch-Ua" => "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"90\"",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
            "Sec-Ch-Ua-Mobile" => "?0",
            "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
            "Accept-Encoding" => "gzip, deflate",
            "Sec-Fetch-Site" => "same-site",
            "Sec-Fetch-Mode" => "cors",
            "Sec-Fetch-Dest" => "empty",
            "Accept-Language" => "en-GB,en-US;q=0.9,en;q=0.8",
            "Connection" => "close",
            ""
        ])

    return r
end

function get_leaderboard(url::S) where {S <: AbstractString}
    r = _get_leaderboard(url)
    # j = JSON.parse(String(r.body))
    j = JSON.parse(String(transcode(GzipDecompressor, r.body)))
    # j = JSON.parse(String(read(ZlibInflateInputStream(r.body))))
    error_if_unsuccessful(j)

    return j[responsekey]
end

function main()
    DotEnv.config()
    session_cookie = ENV["SESSION_COOKIE"]
    error("Pulling self leaderboard from remote is not yet implemented; see ../go or ../rs")
end

main()
