using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;
using Uno.IO;

namespace Bolav.ForeignHelpers {
	public class JSListDict : ListDict {
		Context ctx;
		Fuse.Scripting.Array array;
		Fuse.Scripting.Object cur_row;
		int pos = 0;

		public JSListDict (Context c) {
			ctx = c;
			array = (Fuse.Scripting.Array)ctx.Evaluate("(no file)", "new Array()");
		}
		public override void NewRowSetActive () {
			cur_row = ctx.NewObject();
			array[pos] = cur_row;
			pos++;
		}
		public override void SetRow_Column (string key, string val) {
			cur_row[key] = val;
		}
		public Fuse.Scripting.Array GetScriptingArray () {
			return array;
		}
	}

	public abstract class ListDict {
		public abstract void NewRowSetActive();
		public abstract void SetRow_Column(string key, string val);
	}
}
