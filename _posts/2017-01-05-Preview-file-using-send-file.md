---
layout: post
title: Preview file using send_file
author: bananaapple
tags:
  - ruby on rails
  - send_file

categories:
  - computer science
date: 2017-01-05 16:15:00
---
在 Ruby on rails 裡面

通常都是因為要做檔案權限控管

所以才會使用 `send_file` 這個 method

如果不需要做檔案下載的權限控管的話

直接把檔案放在 public 資料夾即可

有 access control 的檔案下載可以參考這篇 [carrierwave secure upload](https://github.com/carrierwaveuploader/carrierwave/wiki/how-to:-secure-upload)
這樣做完後你的 model 裡就會有一個 download method

來幫你讀檔再用 `send_file` 來送出去

## `app/controllers/challenges_controller.rb`

```ruby
def download
  send_file file_path, disposition: 'inline'
end
```

重點有兩個
1. `:disposition` 參數用來指定是 `inline` 還是 `attachment`，default 是 `attachment`，所以要指定成 `inline`
2. 設定 `:type`，設定 HTTP content type，瀏覽器知道要怎麼呈現這個檔案，就是所謂的 `preview`，通常這個參數可以不用設，它會自動從 `:filename` 裡抓取 file extension 並選擇適當的 MIME type 當作 HTTP content type

#Reference


- [send_file](http://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)
