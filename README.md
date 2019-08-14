# SwitchWatch

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url] 
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

Initially built to aid a research project, SwitchWatch makes it easy to record and export state transitions of items under observation over time. 

Also, a good reason to play around with SwiftUI for the first time.

## Screenshots
Setup Observation            |  Completed Observation
:-------------------------:|:-------------------------:
<img src="https://github.com/moorea/SwitchWatch/blob/master/Images/SessionStart.png" width="375" height="667">  |  <img src="https://github.com/moorea/SwitchWatch/blob/master/Images/SessionComplete.png" width="375" height="667">

## App Features

- [x] Input Group Name, Trial Number, and Trial Day for an observation session
- [x] Configure multiple items to observe simultaneously
- [x] After beginning an observation, toggle an item to record a transition and swap that item's active timer
- [x] Export data

## Example Data Export

After completing an observation session, tap "share" to export two files.

### raw_transition_times.csv

As the name suggests, this file contains all the raw data recorded from every tap of every toggle throughout the session. Importing into excel/sheets/numbers looks something like:

<img src="https://github.com/moorea/SwitchWatch/blob/master/Images/RawDataTable.png" width="425" height="500"> 

### stats.csv

This file provides the rolled-up stats for each item during the observation session:

![StatsTable](https://github.com/moorea/SwitchWatch/blob/master/Images/StatsTable.png)


## Requirements

- iOS 13.0+
- Xcode 11 beta 5
- macOS Catalina (10.15) beta 5

## Installation

1. Fork this repository
2. Build and deploy
3. Congratulations!  

## Contribute

I'd love for you to make a contribution to **SwitchWatch** if you think you can make it more useful for your purposes, check the ``LICENSE`` file for more info.

## Meta

[Andrew Moore](https://www.linkedin.com/in/moorea/) – admoore14@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-5.1-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: https://github.com/moorea/SwitchWatch/blob/master/LICENSE.md
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
