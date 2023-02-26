# TimeSpent

## Overview

`TimeSpent` was designed to get answer the question "How much time I spent on a project for a particular period." The main concern was to track time inside the accustomed environment of a text editor and command line.

Basically it provides two main stories of a project contributor:

1. Contributor tracks time per project by writing timesheets
2. Contributor reports time spent on a project for a period

It designed around a timesheet and supplies contributors with:

- clear and concise timesheet DSL, where one can specify the project, contributor, hourly rate, and collection of tracks;
- CLI reporting, where one can query for a period, project, contributor, or a particular task, and combine the parameters.

TimeSpent assumes that:  

- all timesheets are stored inside `<project_root>/*.timesheet` or `<project_root>/.timespent/*.timesheet`;
- every timesheet belongs exactly to one contributor and one project;
- a contributor can track time among several sheets (e.g. one sheet per month.)

You can see an example of a timesheet right here in [time_spent.timespent](time_spent.timespent) file.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add time_spent --git https://github.com/nvoynov/time_spent.git

Install it yourself if you need reports outside project folders:

    $ git clone https://github.com/nvoynov/time_spent.git
    $ cd time_spent
    $ rake install

## Usage

The flow of using TimeSpent is pretty simple, where

- you track time in `.timesheet` files,
- then run `$ timespent` to get a report.  

To see all CLI options run

    $ timespent help

### Timesheets

You can create the first empty timesheet by running

    $ timespent init

The command will create <directory>.timesheet file.

```ruby
project '<directory>'
contributor '<username>'
hourly_rate 0.00
date_format '%Y-%m-%d'

# track '#{Date.today.prev_day}', task: '#doc', spent: 60, desc: 'TimeSpent'
# track '#{Date.today}', task: '#dev', spent: 60, desc: 'TimeSpent'
```

Once timesheet is created you can track time using DSL

```ruby
track 2023_02_01, spent: 60
track 2023_02_01, spent: 60, task: '#doc', desc: 'some documentation'
track 2023_02_01, spent: '3h30m', task: '#dev', desc: <<~EOF
  some elaborate multiline description
EOF
# etc
```

### Reporting

The `$ timespent [REPORT] [PERIOD] [OPTIONS]` command will load timesheets files and print markdown report into console. When you need to store or send the report to someone else, you can use Pandoc and translate it into any supported format.

    $ timespent | pandoc -s -f markdown -o report.html

The command loads timesheets from:

- project_root/*.timesheet
- project_root/.timespent/*.timesheet

All reports are built around the collection of track objects that respond to `project`, `contributor`, `date`, `spent`, `task`, and `rate`.

__REPORT__

At this moment the command provides the following reports:

- summary
- minutes
- daily
- weekly
- monthly

When the report parameter was not specified, the command will provide the "summary" report so the two following commands are identical

    $ timespent
    $ timespent summary

__PERIOD__

You can specify required period as:

- today | yesterday
- this week | month | year
- prev week | month | year

__OPTIONS__

You can specify filters by providing `--project`, `--contributor`, `--from`, and `--till` options.

__--allround__

The `--allround` option provided will load all sheets in all known folders specified in `<userhome>/.timespent.yml`. This folder list is updated every time you run `$ timespent` command.

Some examples

    $ timespent summary this week --project timespent -- contributor someone
    $ timespent minutes this month
    $ timespent monthly this year
    $ timespent yesterday

### Using Gem

Although I can't see much sense, you could use TimeSpent as Ruby Gem. The following example loads timesheets from all registered folders and returns an array of TrackDecor.

```ruby
require 'time_spent'
include TimeSpent

# where
#   TimeSpent.registered returns array of directories
#   track respond to #project, #contributor, #date, #task, #desc, #rate
tracks = Loader.(TimeSpent.registered)
```   

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/time_spent.
