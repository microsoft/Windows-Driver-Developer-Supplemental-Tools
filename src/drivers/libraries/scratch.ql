import cpp
import Suppression

from SuppressionPopPushSegment spps, SuppressionPragma supp 
where spps.isInPushPopSegment(supp)
select spps, supp