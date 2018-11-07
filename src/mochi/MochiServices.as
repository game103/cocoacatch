class mochi.MochiServices
{
   static var _servicesURL = "http://www.mochiads.com/static/lib/services/services.swf";
   static var _listenChannelName = "__ms_";
   static var _connecting = false;
   static var _connected = false;
   static var netup = true;
   static var netupAttempted = false;
   function MochiServices()
   {
   }
   static function __get__id()
   {
      return mochi.MochiServices._id;
   }
   static function __get__clip()
   {
      return mochi.MochiServices._container;
   }
   static function __get__childClip()
   {
      return mochi.MochiServices._clip;
   }
   static function getVersion()
   {
      return "1.43";
   }
   static function allowDomains(server)
   {
      var _loc1_ = server.split("/")[2].split(":")[0];
      if(System.security)
      {
         if(System.security.allowDomain)
         {
            System.security.allowDomain("*");
            System.security.allowDomain(_loc1_);
         }
         if(System.security.allowInsecureDomain)
         {
            System.security.allowInsecureDomain("*");
            System.security.allowInsecureDomain(_loc1_);
         }
      }
      return _loc1_;
   }
   static function __get__isNetworkAvailable()
   {
      if(System.security)
      {
         var _loc1_ = System.security;
         if(_loc1_.sandboxType == "localWithFile")
         {
            return false;
         }
      }
      return true;
   }
   static function __set__comChannelName(val)
   {
      if(val != undefined)
      {
         if(val.length > 3)
         {
            mochi.MochiServices._sendChannelName = val + "_fromgame";
            mochi.MochiServices.initComChannels();
         }
      }
      return mochi.MochiServices.__get__comChannelName();
   }
   static function __get__connected()
   {
      return mochi.MochiServices._connected;
   }
   static function connect(id, clip, onError)
   {
      if(!mochi.MochiServices._connected && mochi.MochiServices._clip == undefined)
      {
         trace("MochiServices Connecting...");
         mochi.MochiServices._connecting = true;
         mochi.MochiServices.init(id,clip);
      }
      if(onError != undefined)
      {
         mochi.MochiServices.onError = onError;
      }
      else if(mochi.MochiServices.onError == undefined)
      {
         mochi.MochiServices.onError = function(errorCode)
         {
            trace(errorCode);
         };
      }
   }
   static function disconnect()
   {
      if(mochi.MochiServices._connected || mochi.MochiServices._connecting)
      {
         mochi.MochiServices._connecting = mochi.MochiServices._connected = false;
         mochi.MochiServices.flush(true);
         if(mochi.MochiServices._clip != undefined)
         {
            mochi.MochiServices._clip.removeMovieClip();
            delete mochi.MochiServices._clip;
         }
         mochi.MochiServices._listenChannel.close();
      }
   }
   static function init(id, clip)
   {
      mochi.MochiServices._id = id;
      if(clip != undefined)
      {
         mochi.MochiServices._container = clip;
      }
      else
      {
         mochi.MochiServices._container = _root;
      }
      mochi.MochiServices.loadCommunicator(id,mochi.MochiServices._container);
   }
   static function loadCommunicator(id, clip)
   {
      var _loc3_ = "_mochiservices_com_" + id;
      if(mochi.MochiServices._clip != null)
      {
         return mochi.MochiServices._clip;
      }
      if(!mochi.MochiServices.__get__isNetworkAvailable())
      {
         return null;
      }
      if(mochi.MochiServices.urlOptions().servicesURL != undefined)
      {
         mochi.MochiServices._servicesURL = mochi.MochiServices.urlOptions().servicesURL;
      }
      mochi.MochiServices.allowDomains(mochi.MochiServices._servicesURL);
      mochi.MochiServices._clip = clip.createEmptyMovieClip(_loc3_,10336,false);
      mochi.MochiServices._listenChannelName = mochi.MochiServices._listenChannelName + (Math.floor(new Date().getTime()) + "_" + Math.floor(Math.random() * 99999));
      mochi.MochiServices._loader = new MovieClipLoader();
      if(mochi.MochiServices._loaderListener.waitInterval != null)
      {
         clearInterval(mochi.MochiServices._loaderListener.waitInterval);
      }
      mochi.MochiServices._loaderListener = {};
      mochi.MochiServices._loaderListener.onLoadError = function(target_mc, errorCode, httpStatus)
      {
         trace("MochiServices could not load.");
         mochi.MochiServices.disconnect();
         mochi.MochiServices.onError.apply(null,[errorCode]);
      };
      mochi.MochiServices._loaderListener.onLoadStart = function(target_mc)
      {
         this.isLoading = true;
      };
      mochi.MochiServices._loaderListener.startTime = getTimer();
      mochi.MochiServices._loaderListener.wait = function()
      {
         if(getTimer() - this.startTime > 10000)
         {
            if(!this.isLoading)
            {
               mochi.MochiServices.disconnect();
               mochi.MochiServices.onError.apply(null,["IOError"]);
            }
            clearInterval(this.waitInterval);
         }
      };
      mochi.MochiServices._loaderListener.waitInterval = setInterval(mochi.MochiServices._loaderListener,"wait",1000);
      mochi.MochiServices._loader.addListener(mochi.MochiServices._loaderListener);
      mochi.MochiServices._loader.loadClip(mochi.MochiServices._servicesURL + "?listenLC=" + mochi.MochiServices._listenChannelName + "&mochiad_options=" + escape(_root.mochiad_options),mochi.MochiServices._clip);
      mochi.MochiServices._sendChannel = new LocalConnection();
      mochi.MochiServices._sendChannel._queue = [];
      mochi.MochiServices.listen();
      return mochi.MochiServices._clip;
   }
   static function onStatus(infoObject)
   {
      if((var _loc0_ = infoObject.level) === "error")
      {
         mochi.MochiServices._connected = false;
         mochi.MochiServices._listenChannel.connect(mochi.MochiServices._listenChannelName);
      }
   }
   static function listen()
   {
      mochi.MochiServices._listenChannel = new LocalConnection();
      mochi.MochiServices._listenChannel.handshake = function(args)
      {
         mochi.MochiServices.__set__comChannelName(args.newChannel);
      };
      mochi.MochiServices._listenChannel.allowDomain = function(d)
      {
         return true;
      };
      mochi.MochiServices._listenChannel.allowInsecureDomain = mochi.MochiServices._listenChannel.allowDomain;
      mochi.MochiServices._listenChannel._nextcallbackID = 0;
      mochi.MochiServices._listenChannel._callbacks = {};
      mochi.MochiServices._listenChannel.connect(mochi.MochiServices._listenChannelName);
      trace("Waiting for MochiAds services to connect...");
   }
   static function initComChannels()
   {
      if(!mochi.MochiServices._connected)
      {
         mochi.MochiServices._sendChannel.onStatus = function(infoObject)
         {
            mochi.MochiServices.onStatus(infoObject);
         };
         mochi.MochiServices._sendChannel.send(mochi.MochiServices._sendChannelName,"onReceive",{methodName:"handshakeDone"});
         mochi.MochiServices._sendChannel.send(mochi.MochiServices._sendChannelName,"onReceive",{methodName:"registerGame",id:mochi.MochiServices._id,clip:mochi.MochiServices._clip,version:getVersion()});
         mochi.MochiServices._listenChannel.onStatus = function(infoObject)
         {
            mochi.MochiServices.onStatus(infoObject);
         };
         mochi.MochiServices._listenChannel.onReceive = function(pkg)
         {
            var _loc5_ = pkg.callbackID;
            var _loc4_ = this._callbacks[_loc5_];
            if(!_loc4_)
            {
               return undefined;
            }
            var _loc2_ = _loc4_.callbackMethod;
            var _loc3_ = _loc4_.callbackObject;
            if(_loc3_ && typeof _loc2_ == "string")
            {
               _loc2_ = _loc3_[_loc2_];
            }
            if(_loc2_ != undefined)
            {
               _loc2_.apply(_loc3_,pkg.args);
            }
            delete this._callbacks.register5;
         };
         mochi.MochiServices._listenChannel.onError = function()
         {
            mochi.MochiServices.onError.apply(null,["IOError"]);
         };
         trace("connected!");
         mochi.MochiServices._connecting = false;
         mochi.MochiServices._connected = true;
         while(mochi.MochiServices._sendChannel._queue.length > 0)
         {
            mochi.MochiServices._sendChannel.send(mochi.MochiServices._sendChannelName,"onReceive",mochi.MochiServices._sendChannel._queue.shift());
         }
      }
   }
   static function flush(error)
   {
      var _loc1_ = undefined;
      var _loc2_ = undefined;
      while(mochi.MochiServices._sendChannel._queue.length > 0)
      {
         _loc1_ = mochi.MochiServices._sendChannel._queue.shift();
         false;
         if(_loc1_.callbackID != null)
         {
            _loc2_ = mochi.MochiServices._listenChannel._callbacks[_loc1_.callbackID];
         }
         delete mochi.MochiServices._listenChannel._callbacks._loc1_.callbackID;
         if(error)
         {
            mochi.MochiServices.handleError(_loc1_.args,_loc2_.callbackObject,_loc2_.callbackMethod);
         }
      }
   }
   static function handleError(args, callbackObject, callbackMethod)
   {
      if(args != null)
      {
         if(args.onError != null)
         {
            args.onError.apply(null,["NotConnected"]);
         }
         if(args.options != null && args.options.onError != null)
         {
            args.options.onError.apply(null,["NotConnected"]);
         }
      }
      if(callbackMethod != null)
      {
         args = {};
         args.error = true;
         args.errorCode = "NotConnected";
         if(callbackObject != null && typeof callbackMethod == "string")
         {
            callbackObject.callbackMethod(args);
         }
         else if(callbackMethod != null)
         {
            callbackMethod.apply(args);
         }
      }
   }
   static function send(methodName, args, callbackObject, callbackMethod)
   {
      if(mochi.MochiServices._connected)
      {
         mochi.MochiServices._sendChannel.send(mochi.MochiServices._sendChannelName,"onReceive",{methodName:methodName,args:args,callbackID:mochi.MochiServices._listenChannel._nextcallbackID});
      }
      else
      {
         if(mochi.MochiServices._clip == undefined || !mochi.MochiServices._connecting)
         {
            mochi.MochiServices.onError.apply(null,["NotConnected"]);
            mochi.MochiServices.handleError(args,callbackObject,callbackMethod);
            mochi.MochiServices.flush(true);
            return undefined;
         }
         mochi.MochiServices._sendChannel._queue.push({methodName:methodName,args:args,callbackID:mochi.MochiServices._listenChannel._nextcallbackID});
      }
      mochi.MochiServices._listenChannel._callbacks[mochi.MochiServices._listenChannel._nextcallbackID] = {callbackObject:callbackObject,callbackMethod:callbackMethod};
      mochi.MochiServices._listenChannel._nextcallbackID = mochi.MochiServices._listenChannel._nextcallbackID + 1;
   }
   static function urlOptions()
   {
      var _loc5_ = {};
      if(_root.mochiad_options)
      {
         var _loc4_ = _root.mochiad_options.split("&");
         var _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            var _loc3_ = _loc4_[_loc2_].split("=");
            _loc5_[unescape(_loc3_[0])] = unescape(_loc3_[1]);
            _loc2_ = _loc2_ + 1;
         }
      }
      return _loc5_;
   }
   static function addLinkEvent(url, burl, btn, onClick)
   {
      var timeout = 1500;
      var t0 = getTimer();
      var _loc2_ = new Object();
      _loc2_.mav = getVersion();
      _loc2_.swfv = btn.getSWFVersion() || 6;
      _loc2_.swfurl = btn._url;
      _loc2_.fv = System.capabilities.version;
      _loc2_.os = System.capabilities.os;
      _loc2_.lang = System.capabilities.language;
      _loc2_.scres = System.capabilities.screenResolutionX + "x" + System.capabilities.screenResolutionY;
      var s = "?";
      var _loc3_ = 0;
      for(var _loc6_ in _loc2_)
      {
         if(_loc3_ != 0)
         {
            s = s + "&";
         }
         _loc3_ = _loc3_ + 1;
         s = s + _loc6_ + "=" + escape(_loc2_[_loc6_]);
      }
      if(!(mochi.MochiServices.netupAttempted || mochi.MochiServices._connected))
      {
         var ping = btn.createEmptyMovieClip("ping",777);
         var _loc7_ = btn.createEmptyMovieClip("nettest",778);
         mochi.MochiServices.netupAttempted = true;
         ping.loadMovie("http://x.mochiads.com/linkping.swf?t=" + getTimer());
         _loc7_.onEnterFrame = function()
         {
            if(ping._totalframes > 0 && ping._totalframes == ping._framesloaded)
            {
               delete this.onEnterFrame;
            }
            else if(getTimer() - t0 > timeout)
            {
               delete this.onEnterFrame;
               mochi.MochiServices.netup = false;
            }
         };
      }
      var _loc4_ = btn.createEmptyMovieClip("clk",1001);
      _loc4_._alpha = 0;
      _loc4_.beginFill(1044735);
      _loc4_.moveTo(0,0);
      _loc4_.lineTo(0,btn._height);
      _loc4_.lineTo(btn._width,btn._height);
      _loc4_.lineTo(btn._width,0);
      _loc4_.lineTo(0,0);
      _loc4_.endFill();
      _loc4_.onRelease = function()
      {
         if(mochi.MochiServices.netup)
         {
            getURL(url + s,"_blank");
         }
         else
         {
            getURL(burl,"_blank");
         }
         if(onClick != undefined)
         {
            onClick();
         }
      };
   }
}
