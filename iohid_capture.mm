#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOTypes.h>
#include <IOKit/IOReturn.h>
#include <IOKit/hid/IOHIDLib.h>
#import <objc/runtime.h>

#include <stdio.h>
#include <unistd.h>
#include <dlfcn.h>
#include <string>
#include <map>

#include "mach_override/mach_override.h"

typedef struct {
    uint8_t id, 
    left_x, left_y, 
    right_x, right_y, 
    buttons1, buttons2, buttons3, 
    left_trigger, right_trigger, 
    count1, count2, battery;
    int16_t gyro_x, gyro_y, gyro_z;
    int16_t accel_x, accel_y, accel_z;
    uint8_t unk4[39];
} PSReport;

typedef struct {
    IOHIDReportCallback wrappedCallback;
    void* wrappedContext;
} ReportCallback;

void wrappedReportCallback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength)
{
    printf("Recieved report 0x%lx (%i:%i)\n", (unsigned long) sender,(int)type,(int)reportID);
    if( result != kIOReturnSuccess ){
        printf("\tFAILED\n");
    }
    else
    {
        for( int i=0; i < reportLength; i++ )
        {
            printf("0x%x, ",report[i]);
        }
        printf("\n");
    }
    ReportCallback* info = (ReportCallback*)context;
    info->wrappedCallback(info->wrappedContext,result,sender,type,reportID,report,reportLength);
}

void override_hid_manager()
{

    kern_return_t err;
    MACH_OVERRIDE( IOHIDManagerRef, IOHIDManagerCreate, (CFAllocatorRef allocator, IOOptionBits options), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOHIDManagerRef manager = IOHIDManagerCreate_reenter( allocator, options );
        printf("IOHIDManagerCreate: New manager is 0x%lx\n",(unsigned long) manager);
        return manager;
    } END_MACH_OVERRIDE(IOHIDManagerCreate);

    MACH_OVERRIDE( IOReturn, IOHIDManagerOpen, (IOHIDManagerRef manager, IOOptionBits options), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerOpen 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerOpen_reenter( manager, options );
    } END_MACH_OVERRIDE(IOHIDManagerOpen);

    MACH_OVERRIDE( IOReturn, IOHIDManagerClose, (IOHIDManagerRef manager, IOOptionBits options), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerClose 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerClose_reenter( manager, options );
    } END_MACH_OVERRIDE(IOHIDManagerClose);

    MACH_OVERRIDE( CFSetRef, IOHIDManagerCopyDevices, (IOHIDManagerRef manager), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerCopyDevices 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerCopyDevices_reenter( manager );
    } END_MACH_OVERRIDE(IOHIDManagerCopyDevices);

    MACH_OVERRIDE( void, IOHIDManagerRegisterDeviceMatchingCallback, (IOHIDManagerRef manager, IOHIDDeviceCallback callback, void *context), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerRegisterDeviceMatchingCallback 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerRegisterDeviceMatchingCallback_reenter( manager,callback, context );
    } END_MACH_OVERRIDE(IOHIDManagerRegisterDeviceMatchingCallback);

    MACH_OVERRIDE( void, IOHIDManagerRegisterDeviceRemovalCallback, (IOHIDManagerRef manager, IOHIDDeviceCallback callback, void *context), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerRegisterDeviceRemovalCallback 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerRegisterDeviceRemovalCallback_reenter( manager,callback, context );
    } END_MACH_OVERRIDE(IOHIDManagerRegisterDeviceRemovalCallback);

    MACH_OVERRIDE( void, IOHIDManagerSetDeviceMatchingMultiple, (IOHIDManagerRef manager, CFArrayRef multiple), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerSetDeviceMatchingMultiple 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerSetDeviceMatchingMultiple_reenter( manager,multiple );
    } END_MACH_OVERRIDE(IOHIDManagerSetDeviceMatchingMultiple);

    MACH_OVERRIDE( void, IOHIDManagerUnscheduleFromRunLoop, (IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        printf("IOHIDManagerUnscheduleFromRunLoop 0x%lx\n",(unsigned long) manager);
        return IOHIDManagerUnscheduleFromRunLoop_reenter( manager,runLoop,runLoopMode );
    } END_MACH_OVERRIDE(IOHIDManagerUnscheduleFromRunLoop);

    MACH_OVERRIDE( void, IOHIDManagerScheduleWithRunLoop, ( IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOHIDManagerScheduleWithRunLoop_reenter(manager, runLoop, runLoopMode);
        printf("IOHIDManagerScheduleWithRunLoop 0x%lx \n", (unsigned long) manager);
    } END_MACH_OVERRIDE(IOHIDManagerScheduleWithRunLoop);
}

void override_hid_device()
{
    kern_return_t err;
    MACH_OVERRIDE( IOReturn, IOHIDDeviceOpen, (IOHIDDeviceRef device, IOOptionBits options), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOReturn result = IOHIDDeviceOpen_reenter(device,options);
        printf("IOHIDDeviceOpen 0x%lx was %i\n", (unsigned long) device, (int) result);
        return result;
    } END_MACH_OVERRIDE(IOHIDDeviceOpen);

    MACH_OVERRIDE( CFTypeRef, IOHIDDeviceGetProperty, (IOHIDDeviceRef device, CFStringRef key), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        CFTypeRef result = IOHIDDeviceGetProperty_reenter(device,key);
        NSString* keystr = (NSString*) CFCopyDescription( (CFTypeRef)key );
        NSString* objstr = (NSString*) CFCopyDescription( (CFTypeRef)result );
        printf("IOHIDDeviceGetProperty 0x%lx key %s : %s\n", (unsigned long) device, [keystr UTF8String],[objstr UTF8String]);
        [keystr release];
        [objstr release];
        return result;
    } END_MACH_OVERRIDE(IOHIDDeviceGetProperty);

    MACH_OVERRIDE( IOReturn, IOHIDDeviceGetReport, (IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uint8_t *report, CFIndex *pReportLength ), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOReturn result = IOHIDDeviceGetReport_reenter(device,reportType,reportID,report,pReportLength);
        printf("IOHIDDeviceGetReport 0x%lx (%i:%i)\n", (unsigned long) device,(int)reportType,(int)reportID);
        if( result != kIOReturnSuccess ){
            printf("\tFAILED\n");
        }
        else
        {
            for( int i=0; i < *pReportLength; i++ )
            {
                printf("0x%x, ",report[i]);
            }
            printf("\n");
        }
        return result;
    } END_MACH_OVERRIDE(IOHIDDeviceGetReport);


    MACH_OVERRIDE( IOReturn, IOHIDDeviceSetReport, (IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, const uint8_t *report, CFIndex reportLength ), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOReturn result = IOHIDDeviceSetReport_reenter(device,reportType,reportID,report,reportLength);
        printf("IOHIDDeviceSetReport 0x%lx (%i:%i)\n", (unsigned long) device,(int)reportType,(int)reportID);
        if( result != kIOReturnSuccess ){
            printf("\tFAILED\n");
        }
        else
        {
            for( int i=0; i < reportLength; i++ )
            {
                printf("0x%x, ",report[i]);
            }
            printf("\n");
        }
        return result;
    } END_MACH_OVERRIDE(IOHIDDeviceSetReport);

    MACH_OVERRIDE( void, IOHIDDeviceScheduleWithRunLoop, ( IOHIDDeviceRef device, CFRunLoopRef runLoop, CFStringRef runLoopMode), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.
        IOHIDDeviceScheduleWithRunLoop_reenter(device, runLoop, runLoopMode);
        printf("IOHIDDeviceScheduleWithRunLoop 0x%lx \n", (unsigned long) device);
    } END_MACH_OVERRIDE(IOHIDDeviceScheduleWithRunLoop);

    MACH_OVERRIDE( void, IOHIDDeviceRegisterInputReportCallback, ( IOHIDDeviceRef device, uint8_t *report, CFIndex reportLength, IOHIDReportCallback callback, void *context), err ) {
        //  Test calling through the reentry island back into the original
        //  implementation.

        ReportCallback* new_context = (ReportCallback*) malloc( sizeof( ReportCallback ) );
        new_context->wrappedCallback = callback;
        new_context->wrappedContext = context;
        IOHIDDeviceRegisterInputReportCallback_reenter(device,report,reportLength,wrappedReportCallback,new_context);
        printf("IOHIDDeviceRegisterInputReportCallback 0x%lx \n", (unsigned long) device);

            for( int i=0; i < reportLength; i++ )
            {
                printf("0x%x, ",report[i]);
            }
            printf("\n");
    } END_MACH_OVERRIDE(IOHIDDeviceRegisterInputReportCallback);

}

__attribute__((constructor))
static void initialize_hidcapture() {
    printf("Overriding IOHID Functions\n");
    override_hid_manager();
    override_hid_device();
}
