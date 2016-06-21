using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.IO;
using Uno.Compiler.ExportTargetInterop;

namespace Bolav.ForeignHelpers {
	public class JSList : ForeignList {
		Context ctx;
		Fuse.Scripting.Array array;
		int pos = 0;

		public JSList (Context c) {
			ctx = c;
			array = (Fuse.Scripting.Array)ctx.Evaluate("(no file)", "new Array()");
		}
		public override ForeignDict NewDictRow () {
			var r = new JSDict(ctx);
			array[pos] = r.GetScriptingObject();
			pos++;
			return r;
		}
		public Fuse.Scripting.Array GetScriptingArray () {
			return array;
		}

		[Foreign(Language.ObjC)]
		extern(iOS) public void FromiOS (ObjC.Object ary)
		@{
			for(id obj in ary) {
			    if ([obj isKindOfClass:[NSDictionary class]]) {
			    	id<UnoObject> ddict = @{JSList:Of(_this).NewDictRow():Call()};
			    	@{JSDict:Of(ddict).FromiOS(ObjC.Object):Call(obj)};
			    }
			    else {
			    	NSLog(@"Unhandled class JSList.FromiOS: %@", NSStringFromClass([obj class]));
			    }
			}
		@}
	}

	public class JSDict : ForeignDict {
		Context ctx;
		Fuse.Scripting.Object obj;
		public JSDict (Context c) {
			ctx = c;
			obj = ctx.NewObject();
		}

		public Fuse.Scripting.Object GetScriptingObject () {
			return obj;
		}

		[Foreign(Language.ObjC)]
		extern(iOS) public void FromiOS (ObjC.Object dict)
		@{
			for(id key in dict) {
				::id value = [dict objectForKey:key];
			    // NSLog(@"key=%@ value=%@", key, [dict objectForKey:key]);
			    if ([value isKindOfClass:[NSString class]]) {
			        @{JSDict:Of(_this).SetKeyVal(string, string):Call(key, value)};
			    }
			    else if ([value isKindOfClass:[NSDictionary class]]) {
			    	id<UnoObject> ddict = @{JSDict:Of(_this).AddDictForKey(string):Call(key)};
			    	@{JSDict:Of(ddict).FromiOS(ObjC.Object):Call(value)};
			    }
			    else {
			    	NSLog(@"Unhandled class JSDict.FromiOS: %@", NSStringFromClass([value class]));
			    }
			}
		@}

		public override void SetKeyVal (string key, string val) {
			obj[key] = val;
		}

		public override ForeignList AddListForKey (string key) {
			var list = new JSList(ctx);
			obj[key] = list.GetScriptingArray();
			return list;
		}

		public override ForeignDict AddDictForKey (string key) {
			var dict = new JSDict(ctx);
			obj[key] = dict.GetScriptingObject();
			return dict;
		}

	}

	public abstract class ListDict {
		public abstract void NewRowSetActive();
		public abstract void SetRow_Column(string key, string val);
	}

	public abstract class ForeignList {
		public abstract ForeignDict NewDictRow();
	}

	public abstract class ForeignDict {
		public abstract ForeignList AddListForKey(string key);
		public abstract ForeignDict AddDictForKey (string key);
		public abstract void SetKeyVal(string key, string val);
	}


}
