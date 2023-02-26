## [Unreleased]

TODO

summary
minutes
roster
allover

    $ timespent this year --allover --registered

- [ ] `date` should accept integer 20230202, 2023_02_02

```ruby
track 2023_02_02, spent: 5 * 60, task: '#doc'
track 2023_02_02, spent: 5 * 60, task: '#dev'
```

## [0.1.0] - 2023-02-24

- Initial release

## 2023-02-19

Project started from the idea of providing a simple efficient tool for logging time spent working on projects. The first attempt was the Worklog gem, that was developed three years ago and used in a few freelance projects. The reasons to start new gem instead of evolving Worklog are:

- Worklog is rather "sloppy work done" for my current standards
- It could bring more value by providing an initial assessment by PERT/FPA
- As a plus, move my PERT/FPA calculators to new home
- Maybe provide custom estimation sheets generator based on from Punch::Domain::DSL
