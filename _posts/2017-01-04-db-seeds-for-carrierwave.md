---
layout: post
title: db/seeds for carrierwave
author: bananaapple
tags:
  - ruby on rails
  - carrierwave
categories:
  - computer science
date: 2017-01-04 13:58:00
---
這篇主要是紀錄對 Carrierwave 寫 `db/seeds` 的方法

# 單一檔案

Model 是 Material 
其中 attachment 欄位是紀錄檔案的欄位

## `app/models/material.rb`

```ruby
class Material < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader
end
```

通常會把測試的檔案放在 `/test/fixtures/` 資料夾下

我有一個檔案路徑在

- `/test/fixtures/magic`

## `db/seeds.rb`

```ruby
material = Material.new()
material.attachment = File.new(File.join("test/fixtures/files/","magic"))
material.save!
```


# 多個檔案

Database 是使用 sqlite 

所以是用 string 格式來存檔案資訊

[官方 issue](https://github.com/carrierwaveuploader/carrierwave/issues/1755)

我有兩個檔案路徑在

- `/test/fixtures/magic`
- `/test/fixtures/gdb.txt`

## `app/models/challenge.rb`

```ruby
class Challenge < ApplicationRecord
  mount_uploaders :attachments, AttachmentUploader
end
```
## `db/seeds.rb`

```ruby
challenge = Challenge.new()
attachments = [ "magic", "gdb.txt" ]
attachments.map! do | attachment |
  attachment = File.new(File.join("test/fixtures/files/",attachment))
end
challenge.attachments = attachments
challenge.save!
```