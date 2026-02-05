#include "MeetingServiceEvent.h"

void MeetingServiceEvent::onMeetingStatusChanged(MeetingStatus status, int iResult) {
    if (m_onMeetingStatusChanged) {
        m_onMeetingStatusChanged(status, iResult);
        return;
    }

    stringstream ss;
    ss << iResult;
    auto result = ss.str();

    switch (status) {
        case MEETING_STATUS_CONNECTING:
            Log::info("connecting to the meeting");
            break;
        case MEETING_STATUS_RECONNECTING:
            Log::info("reconnecting to the meeting");
            break;
        case MEETING_STATUS_DISCONNECTING:
            Log::info("disconnecting from the meeting");
            break;
        case MEETING_STATUS_INMEETING:
            Log::success("connected");
            if (m_onMeetingJoin) m_onMeetingJoin();
            return;
        case MEETING_STATUS_ENDED:
            Log::success("meeting ended");
            if (m_onMeetingEnd) m_onMeetingEnd();
            return;
        case MEETING_STATUS_FAILED: {
            string hint;
            switch (iResult) {
                case 7:  hint = " (meeting not started yet – host must join first)"; break;
                case 8:  hint = " (meeting does not exist, ended, or invalid ID/link – start meeting and use a fresh join URL)"; break;
                case 63: hint = " (cannot join external meeting with dev credentials – publish app or host from same Zoom account)"; break;
                default: break;
            }
            Log::error("failed to connect to the meeting with MeetingFailCode " + result + hint);
            break;
        }
        case MEETING_STATUS_WAITINGFORHOST:
            Log::info("waiting for the meeting to start");
            break;
        default:
            Log::error("unknown meeting status");
            break;
    }
}

void MeetingServiceEvent::setOnMeetingJoin(const function<void()>& callback) {
    m_onMeetingJoin = callback;
}

void MeetingServiceEvent::setOnMeetingEnd(const function<void()>& callback) {
    m_onMeetingEnd = callback;
}

void MeetingServiceEvent::setOnMeetingStatusChanged(const function<void(MeetingStatus, int)>& callback) {
    m_onMeetingStatusChanged = callback;
}
