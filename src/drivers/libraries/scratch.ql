import cpp
import Suppression

// Testing against fastfat sample
from AssignExpr ae
where fastHasSpecificSuppressionPragma(ae.getLocation(), "28931")
select ae, ae.getFile(), ae.getLocation().getStartLine()