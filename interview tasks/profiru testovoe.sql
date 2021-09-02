USE test_database

--� ����� �������� ���� ������� (�GK�), ���������� �������� �� �������?

SELECT DISTINCT t.name
FROM players_stat p
JOIN teams t ON p.team_id = t.id
WHERE position = 'GK' AND yellow_cards >= 1
;

--����� 90-�� ���������� �������� �������, ��������� �� ������� �� ����� 270 �����?

SELECT DISTINCT first_value(age) OVER (
ORDER BY CASE WHEN p <= 0.9 THEN p END DESC) answer
FROM (
SELECT age, percent_rank() OVER (ORDER BY age) p
FROM players_stat
) t;

--������������� ����� ������� ���� ������ �������� ������ �������� �� ����� ���?
SELECT t.name
FROM teams t
JOIN players_stat p ON p.team_id = t.id
WHERE yellow_cards = (SELECT MAX(yellow_cards) FROM teams)
;

--� ����� �������� ���� �� ������� �������� ������ ���������� ('AT')?
SELECT DISTINCT t.name
FROM player_stat p
JOIN teams t on p.team_id = t.id
WHERE team_id NOT IN (
SELECT DISTINCT team_id 
FROM players_stat
WHERE (position = 'GK' OR position = 'DF' OR position = 'MD') and scores >= 0
) AND scores >= 0 AND position = 'AT'
;

