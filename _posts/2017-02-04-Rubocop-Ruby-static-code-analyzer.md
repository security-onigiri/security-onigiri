---
layout: post
title: Rubocop - Ruby static code analyzer
author: bananaapple
tags:
  - ruby on rails
  - rubocop
  - ruby code formatter
categories:
  - computer science
date: 2017-02-04 13:44:00
---
Rubocop 是一個 Ruby static code analyzer
主要用來 format coding style

# Installation

Add following line to Gemfile.rb
```ruby
gem 'rubocop', require: false
```

# Configuration

Config 可以參考 github 上的 [Config](https://github.com/bbatsov/rubocop/tree/master/config) 資料夾

裡面有三個檔案

- default.yml(主要的)
- enabled.yml(預設開啟的)
- disabled.yml(預設關掉的)

改好後命名為 `.rubocop.yml` 放在 repo 裡，當你執行 `rubocop` 指令的時候就會讀取這個檔案的設定開始檢查語法

以下是我自己用的 Rules

把一些比較麻煩的 rules disable 掉了

```ruby
AllCops:
  Exclude:
    - 'db/migrate/*'
    - 'vendor/**/*'
Rails:
  Enabled: true

Rails/HasAndBelongsToMany:
  Enabled: false

Bundler/OrderedGems:
  Enabled: false

Style/ClassAndModuleChildren:
  Enabled: false

Style/ConditionalAssignment:
  Enabled: false

Style/Documentation:
  Enabled: false

Style/FrozenStringLiteralComment:
  Enabled: false

Style/Next:
  Enabled: false

Style/GuardClause:
    Enabled: false

Metrics/LineLength:
  Enabled: false

Metrics/BlockLength:
  Enabled: false

Metrics/MethodLength:
  Enabled: false

Metrics/AbcSize:
    Enabled: false
```

rubocop 可以幫你自動修正一些語法，只要加上 `--auto-correct` 參數

```bash
rubocop --auto-correct
```

但是有時候想要一步一步修語法，我只想修正有關 `Style` 的語法，就要加上 `--only` 參數，其他以此類推

```bash
rubocop --auto-correct --only Style
rubocop --auto-correct --only HashSyntax
rubocop --auto-correct --only StringLiterals
```
# Rake task

如果要整合 travis ci 在每次 code push 的時候檢查語法的話，就要把 rubocop 寫成 rake task，然後寫成 `rake` default 會跑的 task

在 `lib/tasks/rubocop.rake` 加上這幾行

```ruby
begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new

rescue LoadError # rubocop:disable Lint/HandleExceptions
end
```

然後修改一下 `Rakefile`
```ruby
require_relative 'config/application'

Rails.application.load_tasks
task default: [:rubocop]
```
這樣當你打 `rake` 的時候就會自動幫你檢查語法了


要是有不懂的名詞可以查 [Official document](http://www.rubydoc.info/github/bbatsov/rubocop/Rubocop/)
