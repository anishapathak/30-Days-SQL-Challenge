-- Question :https://leetcode.com/problems/find-users-with-persistent-behavior-patterns/
-- This code right now is not most optimised was just trying my first leet code complex problem
SELECT C.user_id
	,C.action
    ,streak_length
    ,DATEADD(day, (streak_length*-1)+1, action_date) AS start_date
    ,action_date AS end_date
FROM (
	SELECT user_id
		,action
		,max(total_consecutive_days) + 1 AS streak_length
	FROM (
		SELECT user_id
			,action_date
			,action
			,CASE 
				WHEN diff = 1
					THEN sum(diff) OVER (
							PARTITION BY user_id
							,action ORDER BY action_date ASC
							)
				ELSE 0
				END AS total_consecutive_days
		FROM (
			SELECT user_id
				,action_date
				,action
				,LAG(action_date, 1) OVER (
					PARTITION BY user_id
					,action ORDER BY action_date ASC
					) AS previous_day_date
				,CASE 
					WHEN DATEDIFF(dd, LAG(action_date, 1) OVER (
								PARTITION BY user_id
								,action ORDER BY action_date ASC
								), action_date) = 1
						THEN 1
					ELSE 0
					END AS diff
			FROM activity
			) A
		) B
	GROUP BY user_id
		,action
	HAVING max(total_consecutive_days) + 1 > = 5
	) C
INNER JOIN (
	SELECT user_id
		,action_date
		,action
		,CASE 
			WHEN diff = 1
				THEN sum(diff) OVER (
						PARTITION BY user_id
						,action ORDER BY action_date ASC
						)
			ELSE 0
			END AS total_consecutive_days
	FROM (
		SELECT user_id
			,action_date
			,action
			,LAG(action_date, 1) OVER (
				PARTITION BY user_id
				,action ORDER BY action_date ASC
				) AS previous_day_date
			,CASE 
				WHEN DATEDIFF(dd, LAG(action_date, 1) OVER (
							PARTITION BY user_id
							,action ORDER BY action_date ASC
							), action_date) = 1
					THEN 1
				ELSE 0
				END AS diff
		FROM activity
		) x 
        ) ac ON C.user_id = ac.user_id
		AND C.action = ac.action
		AND C.streak_length = ac.total_consecutive_days+1
        order by streak_length DESC , user_id asc
	