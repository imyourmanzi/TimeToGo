//
//  Constants.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/9/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

struct IDs {
    
    static let VC_PAGE_WALKTHROUGH: String = "walkthroughPageVC"
    static let VC_WALKTHROUGH: String      = "walkthroughVC"
    static let VC_TAB_MAIN: String         = "mainTabVC"
    static let VC_NAV_SEARCH: String       = "searchNavVC"
    
    static let SGE_TO_HOME: String      = "unwindToHome"
    static let SGE_VIEW_SAVED: String   = "viewSavedEvent"
    static let SGE_TO_SHARE_CAL: String = "toShareToCal"
    static let SGE_TO_SCHEDULE: String  = "unwindToSchedule"
    
    static let Q_BG_STD: String = "com.timetogo.queue"
    
}

struct CoreDataConstants {
    
    static let ENTITY_NAME: String            = "Trip"
    static let CURRENT_EVENT_NAME_KEY: String = "currentTripName"
    static let FETCH_BY_NAME: String            = "tripName == %@"
    static let SEARCH_BY_NAME: String         = "tripName CONTAINS[c] %@"
    
}

struct UIConstants {
    
    static let STD_DATETIME_FORMAT: String = "M/d/yy '@' h:mm a"
    static let NOT_FOUND: String       = "`Not Found`"
    
}

struct WalkthroughConstants {
    
    static let NOT_FIRST_LAUNCH_KEY: String = "notFirstLaunch"
    static let NUM_PAGES: Int               = 5
    static let WT_IMG_NAMES: [String]       = ["wtHome1", "wtHome2", "wtModify", "wtSchedule", "wtFinal"]
    static let WT_DESCRIPTIONS: [String]    = ["Creating the perfect schedule is easy and quick!  Just select a Category...",
                                               "...and then choose your Event Type.",
                                               "Edit the default schedule in the Modify tab.",
                                               "When you're finished, view your schedule and add it to your Calendar.",
                                               "You're all set! If you have problems, questions, or suggestions, feel free to email Support from the Settings tab.\nHappy Planning!"]
    
}

struct HomeConstants {
    
    static let MIGRATED_DATA_KEY: String            = "migratedData"
    static let EVENT_TIME_LABEL_DEFAULT_KEY: String = "DEFAULT"
    static let EVENT_TIME_LABEL_DEFAULT: String     = "Event Time"
    
}

struct ScheduleConstants {
    
    static let STD_DURATION_FORMAT: String = "h:mm a"
    static let STD_DATE_FORMAT: String     = "M/d/yy"
    
}

struct SettingConstants {
    
    static let SUPPORT_EMAIL: String   = "timetogosupport@mattmanzi.com"
    static let SUPPORT_SUBJECT: String = "Question/Comment/Concern with It's Time To Go"
    static let SUPPORT_SITE: String    = "https://mattmanzi.com/#/tech"
    
}
