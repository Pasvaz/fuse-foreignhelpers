using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.IO;

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

		public override void SetKeyVal (string key, string val) {
			obj[key] = val;
		}

		public override ForeignList AddListForKey (string key) {
			var list = new JSList(ctx);
			obj[key] = list.GetScriptingArray();
			return list;
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
		public abstract void SetKeyVal(string key, string val);
	}


}
