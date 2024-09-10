// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pusher_client/pusher_client.dart';
//
//
// import '../utils.dart';
// import 'laravel_echo.dart';
//
// class PusherNotification {
//   static withdrawApproved(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('withdrawal_approved.$authId')
//         .listen('WithdrawApproved', (e) {
//       debugPrint("WithdrawApproved $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Withdraw Approved');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('WithdrawApproved $err');
//     });
//   }
//
//   static withdrawApprovedLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('withdrawal_approved.$authId');
//       debugPrint('chat-room-leaved');
//     } catch (err) {
//       debugPrint('chat-room-leaved-error $err');
//       eLog('WithdrawRejected $err');
//     }
//   }
//
//   static withdrawReject(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('withdrawal_reject.$authId')
//         .listen('WithdrawRejected', (e) {
//       debugPrint("WithdrawRejected $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Withdraw Rejected');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('WithdrawRejected $err');
//     });
//   }
//
//   static withdrawRejectLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('withdrawal_reject.$authId');
//       debugPrint('chat-room-leaved');
//     } catch (err) {
//       debugPrint('chat-room-leaved-error $err');
//       eLog('WithdrawApproved $err');
//     }
//   }
//
//   ///client Event Start
//   static jobPostApproval(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('job_post_approval.$authId')
//         .listen('JobPublishNotification', (e) {
//       debugPrint("JobPublishNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Job Publish');
//           context.read<NotificationCubit>().countUserNot();
//         }
//       }
//     }).error((err) {
//       eLog('JobPublishNotification $err');
//     });
//   }
//
//   static jobPostApprovalLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('job_post_approval.$authId');
//     } catch (err) {
//       eLog('JobPublishNotification $err');
//     }
//   }
//
//   static newApplication(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('new_application.$authId')
//         .listen('NewApplicationNotification', (e) {
//       debugPrint("NewApplicationNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'New Application');
//           context.read<NotificationCubit>().countUserNot();
//         }
//       }
//     }).error((err) {
//       eLog('NewApplicationNotification $err');
//     });
//   }
//
//   static newApplicationLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('new_application.$authId');
//     } catch (err) {
//       eLog('NewApplicationNotification $err');
//     }
//   }
//
//   ///client Event End
//
//   ///influencer Event Start
//
//   static newJobPost(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('new_jobpost.$authId')
//         .listen('NewJobPostNotification', (e) {
//       debugPrint("NewJobPostNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'New Job Post');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('NewJobPostNotification $err');
//     });
//   }
//
//   static newJobPostLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('new_jobpost.$authId');
//       debugPrint('chat-room-leaved');
//     } catch (err) {
//       debugPrint('chat-room-leaved-error $err');
//       eLog('NewJobPostNotification $err');
//     }
//   }
//
//   static hiredApplicant(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('hired_application.$authId')
//         .listen('HiredNotification', (e) {
//       debugPrint("HiredNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Job Hired');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('HiredNotification $err');
//     });
//   }
//
//   static hiredApplicantLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('hired_application.$authId');
//       // debugPrint('chat-room-leaved');
//     } catch (err) {
//       // debugPrint('chat-room-leaved-error $err');
//       eLog('HiredNotification $err');
//     }
//   }
//
//   static demoApproval(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('demo_approved.$authId')
//         .listen('DemoApprovedNotification', (e) {
//       debugPrint("DemoApprovedNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Demo Approved');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('DemoApprovedNotification $err');
//     });
//   }
//
//   static demoApprovalLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('demo_approved.$authId');
//     } catch (err) {
//       eLog('DemoApprovedNotification $err');
//     }
//   }
//
//   static jobCompleted(BuildContext context, String authId) {
//     LaravelEcho.instance
//         .private('job_completed.$authId')
//         .listen('JobCompleteNotification', (e) {
//       debugPrint("JobCompleteNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'Job Complete');
//           context.read<NotificationCubit>().countSellerNot();
//         }
//       }
//     }).error((err) {
//       eLog('JobCompleteNotification $err');
//     });
//   }
//
//   static jobCompletedLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('job_completed.$authId');
//     } catch (err) {
//       eLog('JobCompleteNotification $err');
//     }
//   }
//
//   ///influencer Event End
//
//   static newMessage(String authId) {
//     LaravelEcho.instance
//         .private('new_message.$authId')
//         .listen('NewMessageNotification', (e) {
//       debugPrint("NewMessageNotification $e");
//       if (e is PusherEvent) {
//         if (e.data != null) {
//           Utils.handleNotification(jsonDecode(e.data!), 'New Message');
//         }
//       }
//     }).error((err) {
//       eLog('NewMessageNotification $err');
//     });
//   }
//
//   static newMessageLeave(String authId) {
//     try {
//       LaravelEcho.instance.leave('new_message.$authId');
//     } catch (err) {
//       eLog('NewMessageNotification $err');
//     }
//   }
// }
