file = "./langs.json"

import json

data = json.load(open(file, "r", encoding="utf-8"))

data = {k: {k2: v2 for k2, v2 in sorted(v.items())} for k, v in sorted(data.items())}

json.dump(data, open(file, "w", encoding="utf-8"), indent=4, ensure_ascii=False)
