;; --------------------------------------------------------------------------------
;;; lsl-mode.el --- major mode for editing LSL scripts (Linden Scripting Language)

;; Copyright (C) 2006 Reinhard Neurocam

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; COMMENTS:
;; This major mode is a simple derived mode from c-mode.el, setting
;; indentation-defaults to be consistent with the SL-editor, and
;; introducing new font-lock keywords

;; To install lsl-mode, put lsl-mode.el in your user elisp directory. I
;; recommend adding the following code to your ~/.emacs file.
;;
;; (add-to-list 'load-path "<path-user-elisp>")
;;(load "lsl-mode.el")
;;(require 'lsl-mode)
;;(setq auto-mode-alist (append auto-mode-alist
;;  (list
;;   '("\\.lsl$" . lsl-mode)
;;   )))

;;; History:

;; Written originally by Reinhard Neurocam
;; Written lslinit extension by Turkey Scofield 2007/02/21
;; Abbrev+Skeleton+Eldoc extensions and some other small changes by Scott Bristol 2007/03/11

(if (and load-file-name
         (equal (file-name-extension load-file-name) "el"))
    (progn
      (byte-compile-file load-file-name)
      (load-file (concat (file-name-sans-extension load-file-name) ".elc")))
  (let ((source-file-name (concat (file-name-sans-extension load-file-name) ".el")))
    (if (file-newer-than-file-p source-file-name load-file-name)
        (progn
          (byte-compile-file source-file-name)
          (load-file load-file-name))
      (progn
        (eval-when-compile
          (let ((load-path
                 (if (and (boundp 'byte-compile-dest-file)
                          (stringp byte-compile-dest-file))
                     (cons (file-name-directory byte-compile-dest-file) load-path)
                   load-path)))
            (load "lsl-error-mode")
            (require 'cc-bytecomp)))

        (load "cc-mode")
        (require 'cc-mode)
        (load "lsl-error-mode")

        ;; -------------------- font-lock settings --------------------

        (defmacro generate-keyword-dependent-code ()
          (let ((lsl-types '("integer" "float" "string" "key" "vector" "rotation" "list"))
                (lsl-keywords '("for" "do" "while" "if" "else" "jump" "@.*"))
                (lsl-events '("at_rot_target" "at_target" "attach" "changed" "collision" "collision_end" "collision_start" "control" "dataserver" "email" "http_response" "land_collision" "land_collision_end" "land_collision_start" "link_message" "listen" "money" "moving_end" "moving_start" "no_sensor" "not_at_rot_target" "not_at_target" "object_rez" "on_rez" "remote_data" "run_time_permissions" "sensor" "state_entry" "state_exit" "timer" "touch" "touch_start" "touch_end"))
                (lsl-event-signatures '("at_rot_target(integer tnum, rotation targetrot, rotation ourrot)" "at_target(integer tnum, vector targetpos, vector ourpos)" "attach(key id)" "changed(integer change)" "collision(integer num_detected)" "collision_end(integer num_detected)" "collision_start(integer num_detected)" "control(key id, integer held, integer change)" "dataserver(key queryid, string data)" "email(string time, string address, string subj, string message, integer num_left)" "http_response(key request_id, integer status, list metadata, string body)" "land_collision(vector pos)" "land_collision_end(vector pos)" "land_collision_start(vector pos)" "link_message(integer sender_num, integer num, string str, key id)" "listen(integer channel, string name, key id, string message)" "money(key id, integer amount)" "moving_end()" "moving_start()" "no_sensor()" "not_at_rot_target()" "not_at_target()" "object_rez(key id)" "on_rez(integer start_param)" "remote_data(integer event_type, key channel, key message_id, string sender, integer idata, string sdata)" "run_time_permissions(integer perm)" "sensor(integer num_detected)" "state_entry()" "state_exit()" "timer()" "touch(integer num_detected)" "touch_start(integer num_detected)" "touch_end(integer num_detected)"))
                (lsl-constants '("TRUE" "FALSE" "PI" "TWO_PI" "PI_BY_TWO" "DEG_TO_RAD" "RAD_TO_DEG" "SQRT2" "NULL_KEY" "ZERO_VECTOR" "ZERO_ROTATION" "DEBUG_CHANNEL" "EOF" "STATUS_PHYSICS" "STATUS_PHANTOM" "STATUS_ROTATE_X" "STATUS_ROTATE_Y" "STATUS_ROTATE_Z" "AGENT" "ACTIVE" "PASSIVE" "SCRIPTED" "PERMISSION_DEBIT" "PERMISSION_TAKE_CONTROLS" "PERMISSION_REMAP_CONTROLS" "PERMISSION_TRIGGER_ANIMATION" "PERMISSION_ATTACH" "PERMISSION_RELEASE_OWNERSHIP" "PERMISSION_CHANGE_LINKS" "PERMISSION_CHANGE_JOINTS" "PERMISSION_CHANGE_PERMISSIONS" "INVENTORY_TEXTURE" "INVENTORY_SOUND" "INVENTORY_OBJECT" "INVENTORY_SCRIPT" "ATTACH_CHEST" "ATTACH_HEAD" "ATTACH_LSHOULDER" "ATTACH_RSHOULDER" "ATTACH_LHAND" "ATTACH_RHAND" "ATTACH_LFOOT" "ATTACH_RFOOT" "ATTACH_BACK" "LAND_LEVEL" "LAND_RAISE" "LAND_LOWER" "LAND_SMALL_BRUSH" "LAND_MEDIUM_BRUSH" "LAND_LARGE_BRUSH" "LINK_SET" "LINK_ROOT" "LINK_ALL_OTHERS" "LINK_ALL_CHILDREN" "CONTROL_FWD" "CONTROL_BACK" "CONTROL_LEFT" "CONTROL_RIGHT" "CONTROL_ROT_LEFT" "CONTROL_ROT_RIGHT" "CONTROL_UP" "CONTROL_DOWN" "CONTROL_LBUTTON" "CONTROL_ML_LBUTTON" "CHANGED_INVENTORY" "CHANGED_COLOR" "CHANGED_SHAPE" "CHANGED_SCALE" "CHANGED_TEXTURE" "CHANGED_LINK" "CHANGED_OWNER" "TYPE_INTEGER" "TYPE_FLOAT" "TYPE_STRING" "TYPE_KEY" "TYPE_VECTOR" "TYPE_QUATERNION" "TYPE_INVALID" "INVENTORY_ALL" "INVENTORY_NONE" "INVENTORY_TEXTURE" "INVENTORY_SOUND" "INVENTORY_LANDMARK" "INVENTORY_CLOTHING" "INVENTORY_OBJECT" "INVENTORY_NOTECARD" "INVENTORY_SCRIPT" "INVENTORY_BODYPART" "INVENTORY_ANIMATION" "INVENTORY_GESTURE" "ALL_SIDES"))
                (lsl-functions '("llAbs" "llAcos" "llAddToLandBanList" "llAddToLandPassList" "llAdjustSoundVolume" "llAllowInventoryDrop" "llAngleBetween" "llApplyImpulse" "llApplyRotationalImpulse" "llAsin" "llAtan2" "llAttachToAvatar" "llAvatarOnSitTarget" "llAxes2Rot" "llAxisAngle2Rot" "llBase64ToInteger" "llBase64ToString" "llBreakAllLinks" "llBreakLink" "llCSV2List" "llCeil" "llClearCameraParams" "llCloseRemoteDataChannel" "llCloud" "llCollisionFilter" "llCollisionSound" "llCollisionSprite" "llCos" "llCreateLink" "llDeleteSubList" "llDeleteSubString" "llDetachFromAvatar" "llDetectedGrab" "llDetectedGroup" "llDetectedKey" "llDetectedLinkNumber" "llDetectedName" "llDetectedOwner" "llDetectedPos" "llDetectedRot" "llDetectedType" "llDetectedVel" "llDialog" "llDie" "llDumpList2String" "llEdgeOfWorld" "llEjectFromLand" "llEmail" "llEscapeURL" "llEuler2Rot" "llFabs" "llFloor" "llForceMouselook" "llFrand" "llGetAccel" "llGetAgentInfo" "llGetAgentSize" "llGetAlpha" "llGetAndResetTime" "llGetAnimation" "llGetAnimationList" "llGetAttached" "llGetBoundingBox" "llGetCameraPos" "llGetCameraRot" "llGetCenterOfMass" "llGetColor" "llGetCreator" "llGetDate" "llGetEnergy" "llGetForce" "llGetFreeMemory" "llGetGMTclock" "llGetGeometricCenter" "llGetInventoryCreator" "llGetInventoryKey" "llGetInventoryName" "llGetInventoryNumber" "llGetInventoryPermMask" "llGetInventoryType" "llGetKey" "llGetLandOwnerAt" "llGetLinkKey" "llGetLinkName" "llGetLinkNumber" "llGetListEntryType" "llGetListLength" "llGetLocalPos" "llGetLocalRot" "llGetMass" "llGetNextEmail" "llGetNotecardLine" "llGetNumberOfNotecardLines" "llGetNumberOfPrims" "llGetNumberOfSides" "llGetObjectDesc" "llGetObjectMass" "llGetObjectName" "llGetObjectPermMask" "llGetOmega" "llGetOwner" "llGetOwnerKey" "llGetParcelFlags" "llGetPermissions" "llGetPermissionsKey" "llGetPos" "llGetPrimitiveParams" "llGetRegionCorner" "llGetRegionFPS" "llGetRegionFlags" "llGetRegionName" "llGetRegionTimeDilation" "llGetRootPosition" "llGetRootRotation" "llGetRot" "llGetScale" "llGetScriptName" "llGetScriptState" "llGetSimulatorHostname" "llGetStartParameter" "llGetStatus" "llGetSubString" "llGetSunDirection" "llGetTexture" "llGetTextureOffset" "llGetTextureRot" "llGetTextureScale" "llGetTime" "llGetTimeOfDay" "llGetTimestamp" "llGetTorque" "llGetUnixTime" "llGetVel" "llGetWallclock" "llGiveInventory" "llGiveInventoryList" "llGiveMoney" "llGround" "llGroundContour" "llGroundNormal" "llGroundRepel" "llGroundSlope" "llHTTPRequest" "llInsertString" "llInstantMessage" "llIntegerToBase64" "llKey2Name" "llLinks" "llList2CSV" "llList2Float" "llList2Integer" "llList2Key" "llList2List" "llList2ListStrided" "llList2Rot" "llList2String" "llList2Vector" "llListFindList" "llListInsertList" "llListRandomize" "llListReplaceList" "llListSort" "llListStatistics" "llListen" "llListenControl" "llListenRemove" "llLoadURL" "llLog" "llLog10" "llLookAt" "llLoopSound" "llLoopSoundMaster" "llLoopSoundSlave" "llMD5String" "llMapDestination" "llMessageLinked" "llMinEventDelay" "llModPow" "llModifyLand" "llMoveToTarget" "llOffsetTexture" "llOpenRemoteDataChannel" "llOverMyLand" "llOwnerSay" "llParcelMediaCommandList" "llParcelMediaQuery" "llParseString2List" "llParseStringKeepNulls" "llParticleSystem" "llPassCollisions" "llPassTouches" "llPlaySound" "llPlaySoundSlave" "llPointAt" "llPow" "llPreloadSound" "llPushObject" "llRefreshPrimURL" "llReleaseCamera" "llReleaseControls" "llRemoteDataReply" "llRemoteDataSetRegion" "llRemoteLoadScriptPin" "llRemoveFromLandBanList" "llRemoveFromLandPassList" "llRemoveInventory" "llRemoveVehicleFlags" "llRequestAgentData" "llRequestInventoryData" "llRequestPermissions" "llRequestSimulatorData" "llResetOtherScript" "llResetScript" "llResetTime" "llRezAtRoot" "llRezObject" "llRot2Angle" "llRot2Axis" "llRot2Euler" "llRot2Fwd" "llRot2Left" "llRot2Up" "llRotBetween" "llRotLookAt" "llRotTarget" "llRotTargetRemove" "llRotateTexture" "llRound" "llSameGroup" "llSay" "llScaleTexture" "llScriptDanger" "llSendRemoteData" "llSensor" "llSensorRemove" "llSensorRepeat" "llSetAlpha" "llSetBuoyancy" "llSetCameraAtOffset" "llSetCameraEyeOffset" "llSetCameraParams" "llSetColor" "llSetDamage" "llSetForce" "llSetForceAndTorque" "llSetHoverHeight" "llSetLinkAlpha" "llSetLinkColor" "llSetLocalRot" "llSetObjectDesc" "llSetObjectName" "llSetParcelMusicURL" "llSetPayPrice" "llSetPos" "llSetPrimURL" "llSetPrimitiveParams" "llSetRemoteScriptAccessPin" "llSetRot" "llSetScale" "llSetScriptState" "llSetSitText" "llSetSoundQueueing" "llSetSoundRadius" "llSetStatus" "llSetText" "llSetTexture" "llSetTextureAnim" "llSetTimerEvent" "llSetTorque" "llSetTouchText" "llSetVehicleFlags" "llSetVehicleFloatParam" "llSetVehicleRotationParam" "llSetVehicleType" "llSetVehicleVectorParam" "llShout" "llSin" "llSitTarget" "llSleep" "llSqrt" "llStartAnimation" "llStopAnimation" "llStopHover" "llStopLookAt" "llStopMoveToTarget" "llStopPointAt" "llStopSound" "llStringLength" "llStringToBase64" "llSubStringIndex" "llTakeCamera" "llTakeControls" "llTan" "llTarget" "llTargetOmega" "llTargetRemove" "llTeleportAgentHome" "llToLower" "llToUpper" "llTriggerSound" "llTriggerSoundLimited" "llUnSit" "llUnescapeURL" "llVecDist" "llVecMag" "llVecNorm" "llVolumeDetect" "llWater" "llWhisper" "llWind" "llXorBase64StringsCorrect"))
                (lsl-deprecated '("llGodLikeRezObject" "llRemoteLoadScript" "llMakeExplosion" "llMakeFire" "llMakeFountain" "llMakeSmoke" "llSound" "llSoundPreload" "llXorBase64Strings"))
                (lsl-warnings '("FIXME" "TODO"))
                (lsl-user-functions "\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\) *(")
                (lsl-user-variables "\\<\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\>")
                (wrap-in-word-delimiters (lambda (s) (concat "\\<" s "\\>")))
                (re-opt (lambda (word-list) (regexp-opt word-list t))))
            (let ((wrap-and-opt (lambda (word-list) (funcall wrap-in-word-delimiters (funcall re-opt word-list)))))
              `(progn
                 (defvar rp-lsl-font-lock-keywords
                   '((,(funcall wrap-and-opt lsl-types) 1 font-lock-type-face)
                     (,(funcall wrap-and-opt lsl-keywords) 1 font-lock-keyword-face)
                     (,(funcall wrap-and-opt lsl-warnings) 1 font-lock-warning-face t)
                     (,(funcall wrap-and-opt lsl-events) 1 font-lock-builtin-face)
                     (,(funcall wrap-and-opt lsl-constants) 1 font-lock-constant-face)
                     (,(funcall wrap-and-opt lsl-functions) 1 font-lock-keyword-face)
                     (,(funcall wrap-and-opt lsl-deprecated) 1 font-lock-warning-face)
                     (,lsl-user-functions 1 font-lock-function-name-face)
                     (,lsl-user-variables 1 font-lock-variable-name-face)))


                 ;; ----- end font-lock settings

                 (defvar lsl-imenu-generic-expression
                   '(("Handlers" ,(concat "^ *" (funcall wrap-and-opt lsl-events) " *([^)]*)$") 1)
                     ("Functions" ,(concat "^" lsl-user-functions) 1)
                     ("States" "^\\(default|state [a-zA-z_][a-zA-z0-9_]*\\) *$" 1)))


                 (defun setup-skeleton-abbrevs ()

                   (setq skeleton-further-elements '((abbrev-mode nil)))

                   (define-skeleton lsl-for-skeleton
                     "Insert a for loop"
                     "Loop-Maximum: "
                     \n >
                     "integer i;"
                     \n >
                     "for(i=0;i<" str | "LOOPMAX" ";i++)"
                     \n >
                     "{"
                     \n >
                     _
                     \n >
                     "}")

                   (define-abbrev c-mode-abbrev-table "forloop" "" 'lsl-for-skeleton)

                   ,@(let ((generate-skeleton-def (lambda (event-name event-signature)
                                                    (let ((skel-name (gensym (replace-regexp-in-string "_" "-" event-name))))
                                                      `(progn
                                                         (define-skeleton ,skel-name
                                                           ,(concat event-name " handler skeleton")
                                                           nil
                                                           \n >
                                                           ,event-signature
                                                           \n >
                                                           "{"
                                                           \n >
                                                           _
                                                           \n >
                                                           "}")
                                                         (define-abbrev c-mode-abbrev-table ,(concat "skel" (replace-regexp-in-string "[^A-Za-z0-9]" "" event-name)) "" ',skel-name))))))
                       (mapcar* (lambda (name signature) (funcall generate-skeleton-def name signature)) lsl-events lsl-event-signatures))

                   (abbrev-mode 1))))))



        (generate-keyword-dependent-code)

        (require 'thingatpt)

        (defvar lsl-ll-function-alist '(("llAbs" . "llAbs(integer val)")
                                        ("llAcos" . "llAcos(float val)")
                                        ("llAddToLandBanList" . "llAddToLandBanList(key agent, float hours)")
                                        ("llAddToLandPassList" . "llAddToLandPassList(key agent, float hours)")
                                        ("llAdjustSoundVolume" . "llAdjustSoundVolume(float volume)")
                                        ("llAllowInventoryDrop" . "llAllowInventoryDrop(integer add)")
                                        ("llAngleBetween" . "llAngleBetween(rotation a, rotation b)")
                                        ("llApplyImpulse" . "llApplyImpulse()")
                                        ("llApplyRotationalImpulse" . "llApplyRotationalImpulse(vector force, integer local)")
                                        ("llAsin" . "llAsin(float val)")
                                        ("llAtan2" . "llAtan2(float y, float x)")
                                        ("llAttachToAvatar" . "llAttachToAvatar(integer attachment)")
                                        ("llAvatarOnSitTarget" . "llAvatarOnSitTarget()")
                                        ("llAxisAngle2Rot" . "llAxisAngle2Rot(vector axis, float angle)")
                                        ("llBase64ToInteger" . "llBase64ToInteger(string str)")
                                        ("llBase64ToString" . "llBase64ToString(string str)")
                                        ("llBreakAllLinks" . "llBreakAllLinks()")
                                        ("llBreakLink" . "llBreakLink(integer linknum)")
                                        ("llCSV2List" . "llCSV2List(string src)")
                                        ("llCeil" . "llCeil(float val)")
                                        ("llClearCameraParams" . "llClearCameraParams()")
                                        ("llCloseRemoteDataChannel" . "llCloseRemoteDataChannel(key channel)")
                                        ("llCloud" . "llCloud(vector offset)")
                                        ("llCollisionFilter" . "llCollisionFilter(string name, key id, integer accept)")
                                        ("llCollisionSound" . "llCollisionSound(string impact_sound, float impact_volume)")
                                        ("llCollisionSprite" . "llCollisionSprite(string impact_sprite)")
                                        ("llCompareTexture" . "llCompareTexture(integer side, key src)")
                                        ("llCos" . "llCos(float theta)")
                                        ("llCreateLink" . "llCreateLink(key target, integer parent)")
                                        ("llDeleteSubList" . "llDeleteSubList(list src, integer start, integer end)")
                                        ("llDeleteSubString" . "llDeleteSubString(string src, integer start, integer end)")
                                        ("llDetachFromAvatar" . "llDetachFromAvatar()")
                                        ("llDetectedGrab" . "llDetectedGrab(integer number)")
                                        ("llDetectedGroup" . "llDetectedGroup(integer number)")
                                        ("llDetectedKey" . "llDetectedKey(integer number)")
                                        ("llDetectedLinkNumber" . "llDetectedLinkNumber(integer number)")
                                        ("llDetectedName" . "llDetectedName(integer number)")
                                        ("llDetectedOwner" . "llDetectedOwner(integer number)")
                                        ("llDetectedPos" . "llDetectedPos(integer number)")
                                        ("llDetectedRot" . "llDetectedRot(integer number)")
                                        ("llDetectedType" . "llDetectedType(integer number)")
                                        ("llDetectedVel" . "llDetectedVel(integer number)")
                                        ("llDialog" . "llDialog(key id, string message, list buttons, integer chat_channel)")
                                        ("llDie" . "llDie()")
                                        ("llDumpList2String" . "llDumpList2String(list src, string separator)")
                                        ("llEdgeOfWorld" . "llEdgeOfWorld(vector pos, vector dir)")
                                        ("llEjectFromLand" . "llEjectFromLand(key user)")
                                        ("llEmail" . "llEmail(string address, string subject, string message)")
                                        ("llEscapeURL" . "llEscapeURL(string url)")
                                        ("llEuler2Rot" . "llEuler2Rot(vector vec)")
                                        ("llFabs" . "llFabs(float num)")
                                        ("llFloor" . "llFloor(val)")
                                        ("llForceMouselook" . "llForceMouselook(integer mouselook)")
                                        ("llFrand" . "llFrand(float max)")
                                        ("llGetAccel" . "llGetAccel()")
                                        ("llGetAgentInfo" . "llGetAgentInfo(key id)")
                                        ("llGetAgentSize" . "llGetAgentSize(key id)")
                                        ("llGetAlpha" . "llGetAlpha(integer face)")
                                        ("llGetAndResetTime" . "llGetAndResetTime()")
                                        ("llGetAnimation" . "llGetAnimation(key id)")
                                        ("llGetAnimationList" . "llGetAnimationList(key id)")
                                        ("llGetAttached" . "llGetAttached()")
                                        ("llGetBoundingBox" . "llGetBoundingBox(key object)")
                                        ("llGetCameraPos" . "llGetCameraPos()")
                                        ("llGetCameraRot" . "llGetCameraRot()")
                                        ("llGetCenterOfMass" . "llGetCenterOfMass()")
                                        ("llGetColor" . "llGetColor(integer face)")
                                        ("llGetCreator" . "llGetCreator()")
                                        ("llGetDate" . "llGetDate()")
                                        ("llGetEnergy" . "llGetEnergy()")
                                        ("llGetForce" . "llGetForce()")
                                        ("llGetFreeMemory" . "llGetFreeMemory()")
                                        ("llGetGMTclock" . "llGetGMTclock()")
                                        ("llGetGeometricCenter" . "llGetGeometricCenter()")
                                        ("llGetInventoryCreator" . "llGetInventoryCreator(string item)")
                                        ("llGetInventoryKey" . "llGetInventoryKey(string name)")
                                        ("llGetInventoryName" . "llGetInventoryName(integer type, integer number)")
                                        ("llGetInventoryNumber" . "llGetInventoryNumber(integer type)")
                                        ("llGetInventoryPermMask" . "llGetInventoryPermMask(string item, integer mask)")
                                        ("llGetInventoryType" . "llGetInventoryType(string name)")
                                        ("llGetKey" . "llGetKey()")
                                        ("llGetLandOwnerAt" . "llGetLandOwnerAt(vector pos)")
                                        ("llGetLinkKey" . "llGetLinkKey(integer linknum)")
                                        ("llGetLinkName" . "llGetLinkName(integer linknum)")
                                        ("llGetLinkNumber" . "llGetLinkNumber()")
                                        ("llGetListEntryType" . "llGetListEntryType(list src, integer index)")
                                        ("llGetListLength" . "llGetListLength(list src)")
                                        ("llGetLocalPos" . "llGetLocalPos()")
                                        ("llGetLocalRot" . "llGetLocalRot()")
                                        ("llGetMass" . "llGetMass()")
                                        ("llGetNextEmail" . "llGetNextEmail(string address, string subject)")
                                        ("llGetNotecardLine" . "llGetNotecardLine(string name, integer line)")
                                        ("llGetNumberOfNotecardLines" . "llGetNumberOfNotecardLines(string name)")
                                        ("llGetNumberOfPrims" . "llGetNumberOfPrims()")
                                        ("llGetNumberOfSides" . "llGetNumberOfSides()")
                                        ("llGetObjectDesc" . "llGetObjectDesc()")
                                        ("llGetObjectMass" . "llGetObjectMass(key id)")
                                        ("llGetObjectName" . "llGetObjectName()")
                                        ("llGetObjectPermMask" . "llGetObjectPermMask(integer mask)")
                                        ("llGetOmega" . "llGetOmega()")
                                        ("llGetOwner" . "llGetOwner()")
                                        ("llGetOwnerKey" . "llGetOwnerKey(key id)")
                                        ("llGetParcelFlags" . "llGetParcelFlags(vector pos)")
                                        ("llGetPermissions" . "llGetPermissions()")
                                        ("llGetPermissionsKey" . "llGetPermissionsKey()")
                                        ("llGetPos" . "llGetPos()")
                                        ("llGetPrimitiveParams" . "llGetPrimitiveParams(list params)")
                                        ("llGetRegionCorner" . "llGetRegionCorner()")
                                        ("llGetRegionFPS" . "llGetRegionFPS()")
                                        ("llGetRegionFlags" . "llGetRegionFlags()")
                                        ("llGetRegionName" . "llGetRegionName()")
                                        ("llGetRegionTimeDilation" . "llGetRegionTimeDilation()")
                                        ("llGetRootPosition" . "llGetRootPosition()")
                                        ("llGetRootRotation" . "llGetRootRotation()")
                                        ("llGetRot" . "llGetRot()")
                                        ("llGetScale" . "llGetScale()")
                                        ("llGetScriptName" . "llGetScriptName()")
                                        ("llGetScriptState" . "llGetScriptState(string name)")
                                        ("llGetSimulatorHostname" . "llGetSimulatorHostname()")
                                        ("llGetStartParameter" . "llGetStartParameter()")
                                        ("llGetStatus" . "llGetStatus(integer status)")
                                        ("llGetSubString" . "llGetSubString(string src, integer start, integer end)")
                                        ("llGetSunDirection" . "llGetSunDirection()")
                                        ("llGetTexture" . "llGetTexture(integer side)")
                                        ("llGetTextureOffset" . "llGetTextureOffset(integer side)")
                                        ("llGetTextureRot" . "llGetTextureRot(integer side)")
                                        ("llGetTextureScale" . "llGetTextureScale(integer side)")
                                        ("llGetTime" . "llGetTime()")
                                        ("llGetTimeOfDay" . "llGetTimeOfDay()")
                                        ("llGetTimestamp" . "llGetTimestamp()")
                                        ("llGetTorque" . "llGetTorque()")
                                        ("llGetUnixTime" . "llGetUnixTime()")
                                        ("llGetVel" . "llGetVel()")
                                        ("llGetWallclock" . "llGetWallclock()")
                                        ("llGiveInventory" . "llGiveInventory(key destination, string inventory)")
                                        ("llGiveInventoryList" . "llGiveInventoryList(key destination, string category, list inventory)")
                                        ("llGiveMoney" . "llGiveMoney()")
                                        ("llGodLikeRezObject" . "llGodLikeRezObject(key inventory, vector pos)")
                                        ("llGroundContour" . "llGroundContour(vector offset)")
                                        ("llGroundNormal" . "llGroundNormal(vector offset)")
                                        ("llGroundRepel" . "llGroundRepel(float height, integer water, float tau)")
                                        ("llGroundSlope" . "llGroundSlope(vector offset)")
                                        ("llHTTPRequest" . "llHTTPRequest(string url, list parameters, string body)")
                                        ("llInsertString" . "llInsertString(string dst, integer position, string src)")
                                        ("llInstantMessage" . "llInstantMessage(key user, string message)")
                                        ("llIntegerToBase64" . "llIntegerToBase64(integer number)")
                                        ("llKey2Name" . "llKey2Name(key id)")
                                        ("llLinks" . "llLinks()")
                                        ("llList2CSV" . "llList2CSV(list src)")
                                        ("llList2Float" . "llList2Float(list src, integer index)")
                                        ("llList2Integer" . "llList2Integer(list src, integer index)")
                                        ("llList2Key" . "llList2Key(list src, integer index)")
                                        ("llList2List" . "llList2List(list src, integer start, integer end)")
                                        ("llList2ListStrided" . "llList2ListStrided(list src, integer start, integer end, integer stride)")
                                        ("llList2Rot" . "llList2Rot(list src, integer index)")
                                        ("llList2String" . "llList2String()")
                                        ("llList2String" . "llList2String(list src, integer index)")
                                        ("llList2Vector" . "llList2Vector(list src, integer index)")
                                        ("llListFindList" . "llListFindList(list src, list test)")
                                        ("llListInsertList" . "llListInsertList(list dest, list src, integer pos)")
                                        ("llListRandomize" . "llListRandomize(list src, integer stride)")
                                        ("llListReplaceList" . "llListReplaceList(list dest, list src, integer start, integer end)")
                                        ("llListSort" . "llListSort(list src, integer stride, integer ascending)")
                                        ("llListStatistics" . "llListStatistics(integer operation, list input)")
                                        ("llListen" . "llListen(integer channel, string name, key id, string msg)")
                                        ("llListenControl" . "llListenControl(integer number, integer active)")
                                        ("llListenRemove" . "llListenRemove(integer number)")
                                        ("llLog" . "llLog(float val)")
                                        ("llLog10" . "llLog10(float val)")
                                        ("llLookAt" . "llLookAt(vector target, F32 strength, F32 damping)")
                                        ("llLoopSound" . "llLoopSound(string sound, float volume)")
                                        ("llLoopSoundMaster" . "llLoopSoundMaster(string sound, float volume)")
                                        ("llLoopSoundSlave" . "llLoopSoundSlave()")
                                        ("llMD5String" . "llMD5String(string src, integer nonce)")
                                        ("llMakeExplosion" . "llMakeExplosion(integer particles, float scale, float velocity, float lifetime, float arc, string texture, vector offset)")
                                        ("llMakeFire" . "llMakeFire(integer particles, float scale, float velocity, float lifetime, float arc, string texture, vector offset)")
                                        ("llMakeFountain" . "llMakeFountain(integer particles, float scale, float velocity, float lifetime, float arc, string texture, vector offset)")
                                        ("llMakeSmoke" . "llMakeSmoke(integer particles, float scale, float velocity, float lifetime, float arc, string texture, vector offset)")
                                        ("llMessageLinked" . "llMessageLinked(integer linknum, integer num, string str, key id)")
                                        ("llMinEventDelay" . "llMinEventDelay(float delay)")
                                        ("llModPow" . "llModPow(integer a, integer b, integer c)")
                                        ("llModifyLand" . "llModifyLand(integer action, integer size)")
                                        ("llMoveToTarget" . "llMoveToTarget(vector target, float tau)")
                                        ("llOffsetTexture" . "llOffsetTexture(float horizontal, float vertical, integer side)")
                                        ("llOpenRemoteDataChannel" . "llOpenRemoteDataChannel()")
                                        ("llOverMyLand" . "llOverMyLand(key id)")
                                        ("llOwnerSay" . "llOwnerSay(string message)")
                                        ("llParseString2List" . "llParseString2List(string src, list separators, list spacers)")
                                        ("llParseStringKeepNulls" . "llParseStringKeepNulls(string src, list separators, list spacers)")
                                        ("llParticleSystem" . "llParticleSystem(list parameters)")
                                        ("llPassCollisions" . "llPassCollisions(TRUE)")
                                        ("llPassTouches" . "llPassTouches(TRUE)")
                                        ("llPlaySound" . "llPlaySound(string sound, float volume)")
                                        ("llPlaySoundSlave" . "llPlaySoundSlave(string sound, float volume)")
                                        ("llPointAt" . "llPointAt(vector pos)")
                                        ("llPow" . "llPow(float base, float exp)")
                                        ("llPreloadSound" . "llPreloadSound(string sound)")
                                        ("llRefreshPrimURL" . "llRefreshPrimURL()")
                                        ("llReleaseCamera" . "llReleaseCamera(key agent)")
                                        ("llReleaseControls" . "llReleaseControls()")
                                        ("llRemoteDataSetRegion" . "llRemoteDataSetRegion()")
                                        ("llRemoveFromLandBanList" . "llRemoveFromLandBanList(key avatar)")
                                        ("llRemoveFromLandPassList" . "llRemoveFromLandPassList(key avatar)")
                                        ("llRemoveInventory" . "llRemoveInventory(string inventory)")
                                        ("llRemoveVehicleFlags" . "llRemoveVehicleFlags(integer flags)")
                                        ("llRequestAgentData" . "llRequestAgentData(key id, integer data)")
                                        ("llRequestInventoryData" . "llRequestInventoryData(string name)")
                                        ("llRequestPermissions" . "llRequestPermissions(key agent, integer perm)")
                                        ("llRequestSimulatorData" . "llRequestSimulatorData(string simulator, integer data)")
                                        ("llResetOtherScript" . "llResetOtherScript(string name)")
                                        ("llResetScript" . "llResetScript()")
                                        ("llResetTime" . "llResetTime()")
                                        ("llRezAtRoot" . "llRezAtRoot(string inventory, vector pos, vector vel, rotation rot, integer param)")
                                        ("llRezObject" . "llRezObject(string inventory, vector pos, vector vel, rotation rot, integer param)")
                                        ("llRot2Angle" . "llRot2Angle(rotation rot)")
                                        ("llRot2Axis" . "llRot2Axis(rotation rot)")
                                        ("llRot2Euler" . "llRot2Euler(rotation rot)")
                                        ("llRot2Left" . "llRot2Left(rotation rot)")
                                        ("llRot2Up" . "llRot2Up(rotation rot)")
                                        ("llRotBetween" . "llRotBetween(vector a, vector b)")
                                        ("llRotLookAt" . "llRotLookAt(rotation target, F32 strength, F32 damping)")
                                        ("llRotLookAt" . "llRotLookAt(rotation target, float strength, float damping)")
                                        ("llRotTarget" . "llRotTarget(rotation rot, float error)")
                                        ("llRotTargetRemove" . "llRotTargetRemove(integer number)")
                                        ("llRotateTexture" . "llRotateTexture(float angle, integer side)")
                                        ("llRound" . "llRound(float value)")
                                        ("llSameGroup" . "llSameGroup(key id)")
                                        ("llSay" . "llSay()")
                                        ("llSay" . "llSay(integer channel, string text)")
                                        ("llScaleTexture" . "llScaleTexture()")
                                        ("llScriptDanger" . "llScriptDanger(vector pos)")
                                        ("llSendRemoteData" . "llSendRemoteData(key channel, string dest, integer idata, string sdata)")
                                        ("llSensor" . "llSensor()")
                                        ("llSensorRemove" . "llSensorRemove()")
                                        ("llSensorRepeat" . "llSensorRepeat(string name, key id, integer type, float range, float arc, float rate)")
                                        ("llSetAlpha" . "llSetAlpha(float alpha, integer face)")
                                        ("llSetBuoyancy" . "llSetBuoyancy(float buoyancy)")
                                        ("llSetCameraAtOffset" . "llSetCameraAtOffset(vector offset)")
                                        ("llSetCameraEyeOffset" . "llSetCameraEyeOffset(vector offset)")
                                        ("llSetCameraParams" . "llSetCameraParams(list rules)")
                                        ("llSetColor" . "llSetColor(vector color, integer face)")
                                        ("llSetDamage" . "llSetDamage(float damage)")
                                        ("llSetForce" . "llSetForce(vector force, integer local)")
                                        ("llSetForceAndTorque" . "llSetForceAndTorque(vector force, vector torque, integer local)")
                                        ("llSetInventoryPermMask" . "llSetInventoryPermMask()")
                                        ("llSetLinkAlpha" . "llSetLinkAlpha(integer linknumber, float alpha, integer face)")
                                        ("llSetLinkColor" . "llSetLinkColor(integer linknumber, vector color, integer face)")
                                        ("llSetLocalPos" . "llSetLocalPos()")
                                        ("llSetLocalRot" . "llSetLocalRot(rotation rot)")
                                        ("llSetObjectDesc" . "llSetObjectDesc(string name)")
                                        ("llSetObjectName" . "llSetObjectName(string name)")
                                        ("llSetObjectPermMask" . "llSetObjectPermMask()")
                                        ("llSetParcelMusicURL" . "llSetParcelMusicURL(string url)")
                                        ("llSetPos" . "llSetPos(vector pos)")
                                        ("llSetPrimURL" . "llSetPrimURL(string url)")
                                        ("llSetPrimitiveParams" . "llSetPrimitiveParams(list rule)")
                                        ("llSetRemoteScriptAccessPin" . "llSetRemoteScriptAccessPin()")
                                        ("llSetRot" . "llSetRot(rotation rot)")
                                        ("llSetScale" . "llSetScale(vector scale)")
                                        ("llSetScriptState" . "llSetScriptState(string name, integer run)")
                                        ("llSetSitText" . "llSetSitText(string text)")
                                        ("llSetSoundQueueing" . "llSetSoundQueueing(integer queue)")
                                        ("llSetSoundRadius" . "llSetSoundRadius(float radius)")
                                        ("llSetStatus" . "llSetStatus(integer status, integer value)")
                                        ("llSetText" . "llSetText(string text, vector color, float alpha)")
                                        ("llSetTexture" . "llSetTexture(string texture, integer side)")
                                        ("llSetTimerEvent" . "llSetTimerEvent(float sec)")
                                        ("llSetTorque" . "llSetTorque(vector torque, integer local)")
                                        ("llSetTouchText" . "llSetTouchText(string text)")
                                        ("llSetVehicleFlags" . "llSetVehicleFlags(integer flag)")
                                        ("llSetVehicleType" . "llSetVehicleType(integer type)")
                                        ("llShout" . "llShout(integer channel, string text)")
                                        ("llSin" . "llSin(float theta)")
                                        ("llSleep" . "llSleep(float sec)")
                                        ("llSoundPreload" . "llSoundPreload(key sound)")
                                        ("llSqrt" . "llSqrt(float val)")
                                        ("llStopAnimation" . "llStopAnimation(string anim)")
                                        ("llStopHover" . "llStopHover()")
                                        ("llStopLookAt" . "llStopLookAt()")
                                        ("llStopMoveToTarget" . "llStopMoveToTarget()")
                                        ("llStopPointAt" . "llStopPointAt()")
                                        ("llStopSound" . "llStopSound()")
                                        ("llStringLength" . "llStringLength(string src)")
                                        ("llStringToBase64" . "llStringToBase64(string str)")
                                        ("llSubStringIndex" . "llSubStringIndex(string source, string pattern)")
                                        ("llTan" . "llTan(float theta)")
                                        ("llTarget" . "llTarget(vector position, float range)")
                                        ("llTargetOmega" . "llTargetOmega(vector axis, float spinrate, float gain)")
                                        ("llTargetRemove" . "llTargetRemove(integer tnumber)")
                                        ("llTeleportAgentHome" . "llTeleportAgentHome(key id)")
                                        ("llToLower" . "llToLower(string src)")
                                        ("llToUpper" . "llToUpper(string src)")
                                        ("llTriggerSound" . "llTriggerSound(key sound, float volume)")
                                        ("llTriggerSoundLimited" . "llTriggerSoundLimited(string sound, float volume, vector tne, vector bsw)")
                                        ("llUnSit" . "llUnSit(key id)")
                                        ("llUnescapeURL" . "llUnescapeURL(string url)")
                                        ("llVecDist" . "llVecDist(vector v1, vector v2)")
                                        ("llVecMag" . "llVecMag(vector v)")
                                        ("llVecNorm" . "llVecNorm(vector v)")
                                        ("llVolumeDetect" . "llVolumeDetect(integer detect)")
                                        ("llWater" . "llWater(vector offset)")
                                        ("llWhisper" . "llWhisper(integer channel, string text)")
                                        ("llWind" . "llWind(vector offset)")
                                        ("llXorBase64Strings" . "llXorBase64Strings(string s1, string s2)")
                                        ("llXorBase64StringsCorrect" . "llXorBase64StringsCorrect(string s1, string s2)")))

        (defun lsl-eldoc-function ()
          (cdr (assoc (thing-at-point 'word) lsl-ll-function-alist)))

        (defvar lsl-checker-lslint-path "~/installtemp/secondlife/lslint/lslint")

        (setq lsl-err-buffer "*LSL SYNTAX ERROR*")

        (defun lsl-call-lslint ()
          "Call lslint and gives current buffer as standart input. After that create '*LSL SYNTAX ERROR*' buffer and display lslint results."
          (interactive)
          (save-excursion
            (let ((lsl-checker-src-buffer (buffer-name)))
              (if (get-buffer lsl-err-buffer)
                  (kill-buffer lsl-err-buffer))
              (switch-to-buffer-other-window lsl-err-buffer)
              (insert lsl-checker-src-buffer "\n")
              (call-process lsl-checker-lslint-path nil t nil "-V")))
          (save-excursion
            (call-process-region
             (point-min) (point-max)
             lsl-checker-lslint-path
             nil
             lsl-err-buffer
             nil)
            (switch-to-buffer lsl-err-buffer)
            (setq buffer-read-only t)
            (lsl-error-mode)
            (shrink-window-if-larger-than-buffer)
            (goto-char (point-min))
            (re-search-forward "^\\(ERROR\\| WARN\\)::" nil t)
            (beginning-of-line)
            (message "lslint done.")))

        (defvar lsl-mode-map nil
          "Keymap for LSL major mode.")

        (if lsl-mode-map
            nil
          (setq lsl-mode-map (copy-keymap c-mode-map))
          (define-key lsl-mode-map "\C-c\C-f" 'lsl-call-lslint)
          (define-key lsl-mode-map "\C-c\C-c" 'comment-region))

        (defun lsl-mode ()
          "Major mode for editing LSL scripts (Linden Scripting Language).

To see what version of CC Mode you are running, enter `\\[c-version]'.

The hook variable `lsl-mode-hook' is run with no args, if that value is
bound and has a non-nil value.  Also the hook `c-mode-common-hook' is
run first.

Key bindings:
\\{c-mode-map}"
          (interactive)
          (c-mode)
          (setq major-mode 'lsl-mode
                mode-name "LSL")
          ;; ----- lsl-specific settings
          ;; (setq c-echo-syntactic-information-p t);; uncomment for syntax/indentation debugging
          (setq indent-tabs-mode nil)
          (setq c-basic-offset 4)
          (setq comment-start "// "
                comment-end   "")
          (setq imenu-generic-expression lsl-imenu-generic-expression)
          (c-set-offset 'substatement-open 0)
          (c-set-offset 'block-open 0)
          (c-set-offset 'statement-cont 0)
          (make-local-variable 'font-lock-defaults)
          (setq font-lock-defaults '(rp-lsl-font-lock-keywords))
          (turn-on-font-lock)
          (setup-skeleton-abbrevs)
          (set (make-local-variable 'eldoc-documentation-function) 'lsl-eldoc-function)
          (eldoc-mode)
          ;;(font-lock-fontify-buffer)
          ;; -----
          (use-local-map lsl-mode-map)
          (run-hooks 'lsl-mode-hook)
          (c-update-modeline))

        (cc-provide 'lsl-mode)))))
;;;
