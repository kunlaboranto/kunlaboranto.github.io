define p1
    p g_cnt_perf

    call print_map_perf ( &g_map_perf.memset)
    call print_map_perf ( &g_map_perf.malloc)
    call print_map_perf ( &g_map_perf.memcpy)
    call print_map_perf ( &g_map_perf.memcmp)
    call print_map_perf ( &g_map_perf.memmove)

    p g_cnt_perf
    #call print_map_perf ( "ALL" )
end

define p2
    p g_cnt_perf

    call print_map_perf ( &g_map_perf.strlen)
    call print_map_perf ( &g_map_perf.strcmp)
    call print_map_perf ( &g_map_perf.strncmp)
    call print_map_perf ( &g_map_perf.strcpy)
    call print_map_perf ( &g_map_perf.strncpy)

    p g_cnt_perf
end

define p3
    p g_cnt_perf

    call print_map_perf ( &g_map_perf.tkill)

    p g_cnt_perf
end

define ww
    #focus cmd
    focus next
end

define pp
    p *this
    p fCnt
end

define ph
    p sHandle
    p &sHandle.mMark
    p *((dbmInternalHandle *)sHandle.mHandle)
    p ((dbmInternalHandle *)sHandle.mHandle)->mError->mErrorMessage
    p ((dbmInternalHandle *)sHandle.mHandle)->mError->mErrorCount
    p ((dbmInternalHandle *)sHandle.mHandle)->mError->mUserErrorCode
    p ((dbmInternalHandle *)sHandle.mHandle)->mError->mInternalErrorCode
    p &((dbmInternalHandle *)sHandle.mHandle)->mError->mInternalErrorCode
end

define v1
    p aCurr->mCurrSlot
    p aNewNode->mChild
    p aNewNode->mIndexSlotHeader.mNodeCount
    p *aNewNode
    p *aCurr
end

define v2
    p sCurr->mCurrSlot
    p sNewNode->mChild
    p sNewNode->mIndexSlotHeader.mNodeCount
    p *sNewNode
    p *sCurr
end

define sync
    call cmnLogFlush()
end

define btall
    thread apply all bt
end

define setprt
    set print pretty on
end

# delete br
define bd
    del br 1 2 3 4 5 6 7 8 9
    info br
end

#set target-wide-charset UTF-8
#set target-wide-charset UCS-4
set breakpoint pending on
#set print pretty on

#br_dir
#br_gd

define br_1
    # 실행하고나서 어떤 시점 이후에 손으로 거는 용도
    #b dbmTransManager::mFindTableInTx
    b dbmSegFreeSlot_
    b dbmSegAllocSlot_
    #b lutil_debug
    #b slap_startup
    #b config_back_initialize
    #b ldif_back_initialize
    #b bdb_back_initialize
    #b dbm_back_initialize
    #b backend_startup_one
    #b backend_startup
    #b db_create
    #b ldap_send_server_request
    #b bdb_dn2id_children
    #b ziplistPush
    #b redisCommand
end

define br_watch
    b main
    #b dbmConnect
    # b cmnTcpRecv
    r
    #wa _cmn_log_echo
    #wa errno if errno == 12 thread 1
    #
    #wa _cmn_errno if _cmn_errno != 0
    #wa _cmn_errno if ( _cmn_errno != 0 && _cmn_errno != -1 && _cmn_errno != 1060 && _cmn_errno != 1027 )
    wa _cmn_errno if _cmn_errno == 1008
    #wa _cmn_errno if _cmn_errno == 1050
    #wa _cmn_errno if _cmn_errno == 1097
    #
    #rb mPShm.*Lib
    #wa g_nCmntLogCountError
    #wa gL.mSpinLock if gL.mSpinLock > 40
    #c
    #dir /home/paul/workspace/demo/./3rd/src/tokyocabinet-1.4.48
    #b utInternalActionSCRIPT
    #b metaManager.cpp:889
    #b bmt_dbm_ex1.cpp:111
    #b dbmRecover.cpp:323
    #b initGlobal
    #b dbmLogFileReader::mFillQueue
    #b dbmReplSender::dbmReplDataCheck
    #b dbmReplSender.cpp:850
    #b dbmDicManager.cpp:1037
    #b dbmTransLogger.cpp:32
end

define pp2
    call mSlotTraceMap->mPrint()
end

#set detach-on-fork off

#b dbmDiskLogger::mFlush
#b complex_table.cpp:116 # if i == 9999
#b _dbm_sigHandler
# b dbmServer.cpp:821
# b _dbm_numa_init

# b dbmLogFileReader::mGetLogByLSN
# b fork

b dbmReplSender.cpp:1685
b dbmReplSender.cpp:1679
#br_watch

# GDB ERR?
#b dbmSegmentManager::AllocSlot

#b dbmSegmentManager::CreateAndInitSegment
#b dbmSegmentManager::Attach
#b shm_open

define br_2
b mDeleteNuInternalCheckLib
b mDeleteNuLeftSiblingLib
b mDeleteNuNonLeftSiblingLib
b mDeleteNuNonRightSiblingLib
b mDeleteNuPositionLib
b mDeleteNuRightSiblingLib

b mInsertAdjustLib
b mInsertCheck
b mInsertClearLib
b mInsertKeyLib
b mInsertKeyPushLib
b mInsertLeafAdjustLib
b mInsertLeafNewAdjustLib
b mInsertNewKeyPushLib
b mInsertNonNewKeyPushLib
b mInsertPositionLib
end

#XX

#b TPAPI001::SetUp
#b TPAPI001::TearDown
#b TPAPI001::TearDownTestCase

#b dbmSegmentManager.cpp:1379

#b dbmSegmentManager.cpp:865
#b cmnShmManager.cpp:127

# b cmnPShmCreate
# b cmnPShmDrop
# b cmnPShmAttach
# b cmnPShmDetach

# b cmnCatchErr
#b dbmLockManager::mInitLock
#b dbmTransManager::mInitTran
#b cmnLogSend 
#b TBKPB001.cpp:115 
#b TBKPB001.cpp:326 
#b cmnTime2StrLib

#b dbmTransManager.cpp:2412
#b dbmLogManager.cpp:204

#b _dbm_sigHandler

#b _dbm_exit
#b pthread_create
#b cmnLogSend

#b TCPERF001B::SetUpTestCase
#b TCPERF001B::SetUp

#b TCPERF001B::TearDownTestCase
#b TCPERF001B::TearDown
#b testSegmentThread.test.cpp:251 if sRC != 0
#b dbmSegmentManager::Create
#b momWriteMemoryStore

# b cmnMemManager::mFreeSlot
# b cmnMemManager::mAllocSlot
#b dbmIndexManager::mDeleteLeftSibling
#b cmnOpenLog


# dir /media/data/paul/workspace/trunk/./src/common/src/module/
