class GoogleDrive
  class << self
    REDIRECT_URL = "https://redirector.googlevideo.com/videoplayback?"
    VIDEO_PLAYBACK = "com/videoplayback?"
    FMT_STREAM_MAP = "fmt_stream_map="
    FMT_LIST = "&fmt_list"
    DOC_GOOGLE = "docs.google.com/file/d/"
    SPREADSHEETS = "https://spreadsheets.google.com/e/get_video_info?docid="
    ITAGS = [{label: "360", itag: "itag=18"}, {label: "480", itag: "itag=59"},
      {label: "720", itag: "itag=22"}, {label: "1080", itag: "itag=37"}]
    DRIVEID = "&driveid"

    # format url:
    # https://docs.google.com/file/d/{file_id}/view
    # https://docs.google.com/file/d/{file_id}/preview
    # https://docs.google.com/file/d/{file_id}/edit
    def list_link_videos url
      file_id = get_file_id url
      spreadsheet_url = SPREADSHEETS + file_id
      body = page_body spreadsheet_url
      body = decode_body body
      url_arr = split_body body
      find_link_mp4(url_arr).flatten
    rescue
      ""
    end

    private
    def get_file_id url
      url.split(DOC_GOOGLE)[1].remove("/view", "/preview", "/edit")
    end

    def page_body url
      agent = Mechanize.new
      page = agent.get url
      page.body
    end

    # We need to decode 2 times of body
    def decode_body body
      URI.unescape (URI.unescape body)
    end

    def split_body body
      result = []
      remove_fmt_stream = body.split(FMT_STREAM_MAP)[1]
      remove_fmt_list = remove_fmt_stream.split(FMT_LIST)[0]
      remove_fmt_list.split("|").each do |link|
        if link.include? "https"
          result << link.split(DRIVEID)[0]
        end
      end
      result
    end

    # Our links that include mp4 and flv. But we only need to use mp4
    def find_link_mp4 links
      links.inject([]) do |result, link|
        result << check_link_video(link)
      end
    end

    def check_link_video link
      result = []
      ITAGS.each do |itag|
        if link.include? itag[:itag]
          link = add_link_redirect_google link
          result << {file: link, type: "mp4", label: itag[:label]}
        end
      end
      result
    end

    def add_link_redirect_google url
      REDIRECT_URL + url.split(VIDEO_PLAYBACK)[1]
    end
  end
end
