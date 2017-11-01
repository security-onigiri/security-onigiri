---
layout: post
title: Rails best practices
author: bananaapple
tags:
  - ruby on rails
categories:
  - computer science
date: 2017-04-21 16:38:00
---
# Introduction

Rails best practices 是一個可以幫你檢查 Rails 專案架構的 gem

比如說你在 route 裡面增加了一些 routing path 但是你的 controller 沒有相對應的 action 的話

它就會幫你檢查出來，並且顯示警告訊息

# Installation

Add following line to Gemfile.rb

```ruby
gem 'rails_best_practices', require: false
gem 'rails_best_practices-rake_task', require: false
```
`rails_best_practices` 是本身檢查架構的 gem
`rails_best_practices-rake_task` 是方便寫 rake task 的 gem

# Customize

要是想要 custom 一些 config

可以打指令產生 config

```bash
rails_best_practices -g
```

會產生 `/config/rails_best_practices.yml`

config 大概長得像這樣

```ruby
#MoveModelLogicIntoModelCheck: { use_count: 4 }
NeedlessDeepNestingCheck: { nested_count: 2 }
NotRescueExceptionCheck: { }
NotUseDefaultRouteCheck: { }
NotUseTimeAgoInWordsCheck: { }
#OveruseRouteCustomizationsCheck: { customize_count: 3 }
ProtectMassAssignmentCheck: { }
RemoveEmptyHelpersCheck: { }
#RemoveTabCheck: { }
```

不想要檢查的 rule 可以直接註解掉即可

# Rake task

如果要整合 travis ci 在每次 code push 的時候檢查架構的話，就要把 rails_best_practices 寫成 rake task，然後寫成 `rake` default 會跑的 task

在 `lib/tasks/rails_best_practices.rake` 加上這幾行

```ruby
require 'rails_best_practices/rake_task'

RailsBestPractices::RakeTask.new
```

然後修改一下 `Rakefile`

```ruby
require_relative 'config/application'

Rails.application.load_tasks
task default: [:rails_best_practices]
```

這樣當你打 `rake` 的時候就會自動幫你檢查架構了

# References
- [Github](https://github.com/railsbp/rails_best_practices)