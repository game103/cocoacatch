class mochi.MochiScores
{
   function MochiScores()
   {
   }
   static function setBoardID(boardID)
   {
      mochi.MochiScores.boardID = boardID;
      mochi.MochiServices.send("scores_setBoardID",{boardID:boardID});
   }
   static function showLeaderboard(options)
   {
      if(options.clip == null || options.clip == undefined)
      {
         options.clip = mochi.MochiServices.clip;
      }
      if(options.clip != mochi.MochiServices.__get__clip() || mochi.MochiServices.__get__childClip()._target == undefined)
      {
         mochi.MochiServices.disconnect();
         mochi.MochiServices.connect(mochi.MochiServices.__get__id(),options.clip);
      }
      delete options.clip;
      if(options.name != null)
      {
         if(typeof options.name == "object")
         {
            if(options.name.text != undefined)
            {
               options.name = options.name.text;
            }
         }
      }
      if(options.score != null)
      {
         if(options.score instanceof TextField)
         {
            if(options.score.text != undefined)
            {
               options.score = options.score.text;
            }
         }
         else if(options.score instanceof mochi.MochiDigits)
         {
            options.score = options.score.value;
         }
         var _loc1_ = Number(options.score);
         if(isNaN(_loc1_))
         {
            trace("ERROR: Submitted score \'" + options.score + "\' will be rejected, score is \'Not a Number\'");
         }
         else if(_loc1_ == -Infinity || _loc1_ == Infinity)
         {
            trace("ERROR: Submitted score \'" + options.score + "\' will be rejected, score is an infinite");
         }
         else
         {
            if(Math.floor(_loc1_) != _loc1_)
            {
               trace("WARNING: Submitted score \'" + options.score + "\' will be truncated");
            }
            options.score = _loc1_;
         }
      }
      if(options.onDisplay != null)
      {
         options.onDisplay();
      }
      else
      {
         mochi.MochiServices.__get__clip().stop();
      }
      if(options.onClose != null)
      {
         mochi.MochiScores.onClose = options.onClose;
      }
      else
      {
         mochi.MochiScores.onClose = function()
         {
            mochi.MochiServices.__get__clip().play();
         };
      }
      if(options.onError != null)
      {
         mochi.MochiScores.onError = options.onError;
      }
      else
      {
         mochi.MochiScores.onError = mochi.MochiScores.onClose;
      }
      if(options.boardID == null)
      {
         if(mochi.MochiScores.boardID != null)
         {
            options.boardID = mochi.MochiScores.boardID;
         }
      }
      mochi.MochiServices.send("scores_showLeaderboard",{options:options},null,mochi.MochiScores.doClose);
   }
   static function closeLeaderboard()
   {
      mochi.MochiServices.send("scores_closeLeaderboard");
   }
   static function getPlayerInfo(callbackObj, callbackMethod)
   {
      mochi.MochiServices.send("scores_getPlayerInfo",null,callbackObj,callbackMethod);
   }
   static function submit(score, name, callbackObj, callbackMethod)
   {
      score = Number(score);
      if(isNaN(score))
      {
         trace("ERROR: Submitted score \'" + String(score) + "\' will be rejected, score is \'Not a Number\'");
      }
      else if(score == -Infinity || score == Infinity)
      {
         trace("ERROR: Submitted score \'" + String(score) + "\' will be rejected, score is an infinite");
      }
      else
      {
         if(Math.floor(score) != score)
         {
            trace("WARNING: Submitted score \'" + String(score) + "\' will be truncated");
         }
         score = Number(score);
      }
      mochi.MochiServices.send("scores_submit",{score:score,name:name},callbackObj,callbackMethod);
   }
   static function requestList(callbackObj, callbackMethod)
   {
      mochi.MochiServices.send("scores_requestList",null,callbackObj,callbackMethod);
   }
   static function scoresArrayToObjects(scores)
   {
      var _loc5_ = {};
      var _loc1_ = undefined;
      var _loc4_ = undefined;
      var _loc2_ = undefined;
      var _loc6_ = undefined;
      for(var _loc8_ in scores)
      {
         if(typeof scores[_loc8_] == "object")
         {
            if(scores[_loc8_].cols != null && scores[_loc8_].rows != null)
            {
               _loc5_[_loc8_] = [];
               _loc2_ = scores[_loc8_];
               _loc4_ = 0;
               while(_loc4_ < _loc2_.rows.length)
               {
                  _loc6_ = {};
                  _loc1_ = 0;
                  while(_loc1_ < _loc2_.cols.length)
                  {
                     _loc6_[_loc2_.cols[_loc1_]] = _loc2_.rows[_loc4_][_loc1_];
                     _loc1_ = _loc1_ + 1;
                  }
                  _loc5_[_loc8_].push(_loc6_);
                  _loc4_ = _loc4_ + 1;
               }
            }
            else
            {
               _loc5_[_loc8_] = {};
               for(var _loc7_ in scores[_loc8_])
               {
                  _loc5_[_loc8_][_loc7_] = scores[_loc8_][_loc7_];
               }
            }
         }
         else
         {
            _loc5_[_loc8_] = scores[_loc8_];
         }
      }
      return _loc5_;
   }
   static function doClose(args)
   {
      if(args.error == true)
      {
         if(args.errorCode == undefined)
         {
            args.errorCode = "IOError";
         }
         mochi.MochiScores.onError.apply(null,[args.errorCode]);
      }
      else
      {
         mochi.MochiScores.onClose.apply();
      }
   }
}
