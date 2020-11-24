require "http"
require "colorize"
require "file_utils"

def fetch_thread(thread_url : String, last_page = 1, skip_cached = true) : Nil
  thread_url += "/" unless thread_url.ends_with?("/")
  unless match = thread_url.match(/\.(\d+)\/?$/)
    return puts "INVALID URL: #{thread_url}"
  end

  thread_id = match[1].to_i
  puts "- thread_id: [#{thread_id}]".colorize.cyan

  dir = File.join("_db", "thread-#{thread_id}")
  FileUtils.mkdir_p(dir)

  (1..last_page).each_with_index do |page, idx|
    file = File.join(dir, "page-#{page}.html")
    next if skip_cached && File.exists?(file)

    url = page > 1 ? File.join(thread_url, "page-#{page}") : thread_url
    # puts "- HIT: #{url} (#{idx + 1}/#{last_page})".colorize.blue

    HTTP::Client.get(url, tls: true) do |res|
      File.write(file, res.body_io.gets_to_end)
      puts "- [#{thread_id}/page-#{page}] archived".colorize.yellow
    end
  end
end

fetch_thread("https://voz.vn/t/tat-ca-cac-bai-bao-sau-bau-cu-ve-my-post-vao-day-khong-lap-cac-cac-topic-khac-auto-xoa-ban.173809/", 290)

# fetch_thread("https://voz.vn/t/chiec-may-tinh-bi-an-co-the-lam-xoay-chuyen-cuc-dien-bau-cu-my-gio-chot.163037/", 537)

# fetch_thread("https://voz.vn/t/bau-cu-tong-thong-my-tat-ca-vao-day-lap-topic-ngoai-gan-ghep-cau-no-trumpet-xoa-va-ban.169124/", last_page: 1268)
