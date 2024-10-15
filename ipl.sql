-- Top 10 batsman having highest score.
select batter, sum(batsman_runs) as total from deliveries
group by batter 
order by total desc limit 10;

-- Highest run scorers in each season.
select batter, sum(batsman_runs) as total , matches.season as season 
from deliveries join matches 
on deliveries.match_id = matches.id
group by batter , season
order by total desc, season asc
limit 15;

-- Highest wickets taken bowlers over the years. 
select bowler, count(dismissal_kind) as total from deliveries
where dismissal_kind = 'caught' or dismissal_kind = 'bowled' or dismissal_kind = 'stumped' or dismissal_kind = 'caught and bowled'
or dismissal_kind = 'lbw'
group by bowler
order by total desc limit 10;

-- Most wickets in a single season.
select bowler, count(dismissal_kind) as total_wickets , matches.season as season
from deliveries
join matches on matches.id = deliveries.match_id
where dismissal_kind = 'caught' or dismissal_kind = 'bowled' or dismissal_kind = 'stumped' or dismissal_kind = 'caught and bowled'
or dismissal_kind = 'lbw'
group by bowler, season
order by total_wickets desc , season asc limit 10;

-- Most consistent bowlers in terms of average economy rate over the years.
select bowler, (t/o) as economy from
(select bowler, sum(total_runs) as t , round(count(`over`)/ 6 , 2) as o from deliveries
group by bowler) as h
order by economy;

-- How do teams perform when chasing versus setting a target.
select toss_decision, count(toss_decision) as wins from
(select toss_winner,toss_decision , winner from matches
where toss_winner = winner) as t
group by toss_decision;

-- Which batsman scores the most runs in the powerplay, middle overs and death overs.
SELECT 
    batter,
    SUM(CASE WHEN deliveries.over IN (0, 1, 2, 3, 4, 5) THEN total_runs ELSE 0 END) AS powerplay_total_runs,
    SUM(CASE WHEN deliveries.over IN (6, 7, 8, 9, 10, 11, 12, 13, 14, 15) THEN total_runs ELSE 0 END) AS middle_over_total,
    SUM(CASE WHEN deliveries.over IN (16, 17, 18, 19) THEN total_runs ELSE 0 END) AS death_total_runs
FROM deliveries
GROUP BY batter
ORDER BY powerplay_total_runs desc, middle_over_total desc, death_total_runs desc ;

-- What is the average score at different venues.
select venue, round(avg(target_runs),2) as target_avg, round(avg(target_runs - result_margin),2) as chase_avg from matches
group by venue
order by target_avg, chase_avg;

-- Are there venues where teams consistently win more matches while chasing.
SELECT matches.venue, COUNT(matches.venue) AS total_matches, t.wins_while_chasing 
FROM 
    (SELECT venue, COUNT(winner) AS wins_while_chasing 
     FROM matches 
     WHERE toss_winner = winner 
     GROUP BY venue) AS t 
LEFT JOIN matches 
    ON matches.venue = t.venue 
GROUP BY matches.venue, t.wins_while_chasing
ORDER BY wins_while_chasing DESC;

-- Top 10 players having best strike rate in the final overs of the match.
SELECT 
    batter, 
    (SUM(CASE WHEN deliveries.over IN (16, 17, 18, 19) THEN total_runs ELSE 0 END) / 
     COUNT(CASE WHEN deliveries.over IN (16, 17, 18, 19) THEN ball ELSE NULL END)) * 100 AS strike_rate
FROM deliveries
GROUP BY batter
ORDER BY strike_rate DESC;


-- Which players have hit the most sixes in a single season.
SELECT season, deliveries.batter, COUNT(deliveries.total_runs) AS sixes
FROM matches JOIN deliveries 
ON deliveries.match_id = matches.id
WHERE deliveries.total_runs = 6
GROUP BY season , deliveries.batter
ORDER BY sixes DESC;

-- Average scores in IPL matchs over the years.
SELECT season, round(avg(target_runs),2) as avg_target_runs, round(avg(target_runs - result_margin),2) as avg_chase_runs 
from matches
group by season;


-- Battinng pairs have been the most successful in terms of run partnerships. 
SELECT batter, non_striker, SUM(total_runs) AS partnership
FROM deliveries
GROUP BY batter , non_striker
ORDER BY partnership DESC;


-- Particular bowler dismissed a specific batsman, creating key rivalries.
SELECT batter, bowler, COUNT(player_dismissed) AS dismissal
FROM deliveries
WHERE batter = batter
GROUP BY batter , bowler
ORDER BY dismissal DESC;

-- Bowlers has consistently taken wickets in high-pressure situations like death overs.
SELECT bowler, COUNT(dismissal_kind) AS dismissal
FROM deliveries
WHERE
    deliveries.over IN (16 , 17, 18, 19)
        AND dismissal_kind = 'caught'
        OR dismissal_kind = 'bowled'
        OR dismissal_kind = 'stumped'
        OR dismissal_kind = 'caught and bowled'
        OR dismissal_kind = 'lbw'
GROUP BY bowler
ORDER BY dismissal DESC;


-- Which team has the best bowling attack in terms of dot ball percentage and overall wickets taken.
SELECT a.bowling_team, a.total_dots, a.per_dots, b.total_wickets, b.per_wickets from
(SELECT *, round((total_dots/sum(total_dots) OVER())*100,2) AS per_dots FROM
(SELECT bowling_team,sum(dots) AS total_dots FROM
(SELECT bowler,bowling_team, COUNT(total_runs) AS dots
FROM deliveries
WHERE
    total_runs = 0
GROUP BY bowler, bowling_team
ORDER BY dots DESC) as t 
GROUP BY bowling_team
ORDER BY total_dots DESC) as d) as a
JOIN
(SELECT *, round((total_wickets/sum(total_wickets) over())*100,2) AS per_wickets FROM
(SELECT bowling_team,sum(wickets) AS total_wickets FROM
(SELECT bowler,bowling_team, COUNT(is_wicket) AS wickets
FROM deliveries
WHERE is_wicket = 1
GROUP BY bowler, bowling_team) as w
GROUP BY bowling_team
ORDER BY total_wickets DESC) AS h) as b
ON a.bowling_team = b.bowling_team;


-- Best finishers in death overs.
SELECT deliveries.batter,
    COUNT(DISTINCT CONCAT(deliveries.match_id, deliveries.inning)) AS innings_played,
    SUM(deliveries.batsman_runs) AS total_runs
FROM deliveries 
JOIN matches ON deliveries.match_id = matches.id
WHERE deliveries.over IN (16, 17, 18, 19) 
GROUP BY deliveries.batter
ORDER BY total_runs DESC;








