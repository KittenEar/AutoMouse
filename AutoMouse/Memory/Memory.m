//
//  Memory.m
//  AutoMouse
//
//  Created by cat-07 on 2016/03/07.
//  Copyright © 2016年 cat-07. All rights reserved.
//

#import "Memory.h"
#import <mach/mach.h>

@implementation Memory

- (vm_size_t)usedMem {
    
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    if (task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count) != KERN_SUCCESS)
    {
        NSLog(@"%s(): Error in task_info(): %s",
              __FUNCTION__, strerror(errno));
    }
    
    // メモリ使用量(bytes)
    vm_size_t rss = t_info.resident_size;
    
    return rss;
}

@end
