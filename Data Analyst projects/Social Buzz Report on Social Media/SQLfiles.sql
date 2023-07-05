SELECT r.column1 AS ReactionID, r.content_id, r.reaction_type, r.Datetime,
       c.content_type, c.category, 
       rt.sentiment, rt.score
FROM [dbo].[Reactions] r
JOIN [dbo].[Content] c ON r.content_id = c.content_id
JOIN [dbo].[ReactionTypes] rt ON r.reaction_type = rt.type;






SELECT c.Category, SUM(rt.Score) AS TotalScore
FROM [dbo].[Content] c
JOIN [dbo].[Reactions] r ON c.Content_ID = r.Content_ID
JOIN [dbo].[ReactionTypes] rt ON r.Reaction_Type = rt.Type
GROUP BY c.Category
ORDER BY TotalScore DESC;
LIMIT 5;