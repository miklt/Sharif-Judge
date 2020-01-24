--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: shj_assignments; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_assignments (
    id integer NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    problems smallint NOT NULL,
    total_submits integer NOT NULL,
    open smallint NOT NULL,
    scoreboard smallint NOT NULL,
    javaexceptions smallint NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    start_time timestamp without time zone NOT NULL,
    finish_time timestamp without time zone NOT NULL,
    extra_time integer NOT NULL,
    late_rule text NOT NULL,
    participants text DEFAULT ''::text NOT NULL,
    moss_update character varying(30) DEFAULT 'Never'::character varying NOT NULL
);


ALTER TABLE public.shj_assignments OWNER TO sharifjudge;

--
-- Name: shj_assignments_classes; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_assignments_classes (
    assignment_id integer NOT NULL,
    class_id integer
);


ALTER TABLE public.shj_assignments_classes OWNER TO sharifjudge;

--
-- Name: shj_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: sharifjudge
--

CREATE SEQUENCE public.shj_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shj_assignments_id_seq OWNER TO sharifjudge;

--
-- Name: shj_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sharifjudge
--

ALTER SEQUENCE public.shj_assignments_id_seq OWNED BY public.shj_assignments.id;


--
-- Name: shj_classes; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_classes (
    id integer NOT NULL,
    time_start character varying(5) NOT NULL,
    time_end character varying(5) NOT NULL,
    day integer NOT NULL,
    classroom character varying(20) NOT NULL,
    class_name character varying(20) NOT NULL
);


ALTER TABLE public.shj_classes OWNER TO sharifjudge;

--
-- Name: shj_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: sharifjudge
--

CREATE SEQUENCE public.shj_classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shj_classes_id_seq OWNER TO sharifjudge;

--
-- Name: shj_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sharifjudge
--

ALTER SEQUENCE public.shj_classes_id_seq OWNED BY public.shj_classes.id;


--
-- Name: shj_notifications; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_notifications (
    id integer NOT NULL,
    title character varying(200) DEFAULT ''::character varying NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    "time" timestamp without time zone NOT NULL
);


ALTER TABLE public.shj_notifications OWNER TO sharifjudge;

--
-- Name: shj_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: sharifjudge
--

CREATE SEQUENCE public.shj_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shj_notifications_id_seq OWNER TO sharifjudge;

--
-- Name: shj_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sharifjudge
--

ALTER SEQUENCE public.shj_notifications_id_seq OWNED BY public.shj_notifications.id;


--
-- Name: shj_problems; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_problems (
    assignment smallint NOT NULL,
    id smallint NOT NULL,
    name character varying(50) DEFAULT ''::character varying NOT NULL,
    score integer NOT NULL,
    is_upload_only smallint DEFAULT 0::smallint NOT NULL,
    has_script smallint DEFAULT 0::smallint NOT NULL,
    c_time_limit integer DEFAULT 500 NOT NULL,
    python_time_limit integer DEFAULT 1500 NOT NULL,
    java_time_limit integer DEFAULT 2000 NOT NULL,
    memory_limit integer DEFAULT 50000 NOT NULL,
    allowed_languages text DEFAULT ''::text NOT NULL,
    diff_cmd character varying(20) DEFAULT 'diff'::character varying NOT NULL,
    diff_arg character varying(20) DEFAULT '-bB'::character varying NOT NULL,
    weight integer NOT NULL
);


ALTER TABLE public.shj_problems OWNER TO sharifjudge;

--
-- Name: shj_queue; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_queue (
    id integer NOT NULL,
    submit_id integer NOT NULL,
    username character varying(20) NOT NULL,
    assignment smallint NOT NULL,
    problem smallint NOT NULL,
    type character varying(8) NOT NULL
);


ALTER TABLE public.shj_queue OWNER TO sharifjudge;

--
-- Name: shj_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: sharifjudge
--

CREATE SEQUENCE public.shj_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shj_queue_id_seq OWNER TO sharifjudge;

--
-- Name: shj_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sharifjudge
--

ALTER SEQUENCE public.shj_queue_id_seq OWNED BY public.shj_queue.id;


--
-- Name: shj_scoreboard; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_scoreboard (
    assignment smallint NOT NULL,
    scoreboard text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.shj_scoreboard OWNER TO sharifjudge;

--
-- Name: shj_sessions; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_sessions (
    session_id character varying(40) DEFAULT '0'::character varying NOT NULL,
    ip_address character varying(45) DEFAULT '0'::character varying NOT NULL,
    user_agent character varying(120) NOT NULL,
    last_activity integer DEFAULT 0 NOT NULL,
    user_data text NOT NULL
);


ALTER TABLE public.shj_sessions OWNER TO sharifjudge;

--
-- Name: shj_settings; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_settings (
    shj_key character varying(50) NOT NULL,
    shj_value text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.shj_settings OWNER TO sharifjudge;

--
-- Name: shj_submissions; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_submissions (
    submit_id integer NOT NULL,
    username character varying(20) NOT NULL,
    assignment smallint NOT NULL,
    problem smallint NOT NULL,
    is_final smallint DEFAULT 0 NOT NULL,
    "time" timestamp without time zone NOT NULL,
    status character varying(100) NOT NULL,
    pre_score integer NOT NULL,
    coefficient character varying(6) NOT NULL,
    file_name character varying(30) NOT NULL,
    main_file_name character varying(30) NOT NULL,
    file_type character varying(6) NOT NULL
);


ALTER TABLE public.shj_submissions OWNER TO sharifjudge;

--
-- Name: shj_users; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_users (
    id integer NOT NULL,
    username character varying(20) NOT NULL,
    password character varying(100) NOT NULL,
    display_name character varying(40) DEFAULT ''::character varying NOT NULL,
    email character varying(40) NOT NULL,
    role character varying(20) NOT NULL,
    passchange_key character varying(60) DEFAULT ''::character varying NOT NULL,
    passchange_time timestamp without time zone,
    first_login_time timestamp without time zone,
    last_login_time timestamp without time zone,
    selected_assignment smallint DEFAULT 0 NOT NULL,
    dashboard_widget_positions character varying(500) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.shj_users OWNER TO sharifjudge;

--
-- Name: shj_users_classes; Type: TABLE; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE TABLE public.shj_users_classes (
    user_id integer NOT NULL,
    class_id integer NOT NULL,
    responsible integer NOT NULL
);


ALTER TABLE public.shj_users_classes OWNER TO sharifjudge;

--
-- Name: shj_users_id_seq; Type: SEQUENCE; Schema: public; Owner: sharifjudge
--

CREATE SEQUENCE public.shj_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shj_users_id_seq OWNER TO sharifjudge;

--
-- Name: shj_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sharifjudge
--

ALTER SEQUENCE public.shj_users_id_seq OWNED BY public.shj_users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_assignments ALTER COLUMN id SET DEFAULT nextval('public.shj_assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_classes ALTER COLUMN id SET DEFAULT nextval('public.shj_classes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_notifications ALTER COLUMN id SET DEFAULT nextval('public.shj_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_queue ALTER COLUMN id SET DEFAULT nextval('public.shj_queue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_users ALTER COLUMN id SET DEFAULT nextval('public.shj_users_id_seq'::regclass);


--
-- Data for Name: shj_assignments; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_assignments (id, name, problems, total_submits, open, scoreboard, javaexceptions, description, start_time, finish_time, extra_time, late_rule, participants, moss_update) FROM stdin;
3	Laboratório 2 ( vim, gcc, gdb e make)	3	182	1	0	0		2020-01-22 15:00:00	2020-01-22 17:00:00	0	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;	ALL	Never
5	Laboratório 3 (Máquina de Turing)	4	5	0	0	0		2020-01-27 15:00:00	2020-01-27 18:00:00	0	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;	ALL	Never
2	Laboratório 1 (CL Mystery)	1	58	1	0	0		2020-01-22 15:00:00	2020-01-22 17:00:00	0	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;	ALL	Never
1	Laboratório 1 (Introdução ao Unix)	7	385	1	0	0		2020-01-22 15:00:00	2020-01-22 17:00:00	0	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;	ALL	Never
4	Laboratório 2 (Expressões regulares)	1	52	1	0	0		2020-01-22 15:00:00	2020-01-22 17:00:00	0	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;	ALL	Never
\.


--
-- Data for Name: shj_assignments_classes; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_assignments_classes (assignment_id, class_id) FROM stdin;
5	\N
3	\N
4	\N
1	\N
2	\N
\.


--
-- Name: shj_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sharifjudge
--

SELECT pg_catalog.setval('public.shj_assignments_id_seq', 1, false);


--
-- Data for Name: shj_classes; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_classes (id, time_start, time_end, day, classroom, class_name) FROM stdin;
\.


--
-- Name: shj_classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sharifjudge
--

SELECT pg_catalog.setval('public.shj_classes_id_seq', 1, false);


--
-- Data for Name: shj_notifications; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_notifications (id, title, text, "time") FROM stdin;
\.


--
-- Name: shj_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sharifjudge
--

SELECT pg_catalog.setval('public.shj_notifications_id_seq', 1, false);


--
-- Data for Name: shj_problems; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_problems (assignment, id, name, score, is_upload_only, has_script, c_time_limit, python_time_limit, java_time_limit, memory_limit, allowed_languages, diff_cmd, diff_arg, weight) FROM stdin;
1	1	Exercício 1	100	1	1	500	1500	2000	50000	Zip	diff	-bB	94
1	2	Exercício 2	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
1	3	Exercício 3	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
1	4	Exercício 4	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
1	5	Exercício 5	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
1	6	Exercício 6	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
1	7	Exercício 7	100	1	1	500	1500	2000	50000	Zip	diff	-bB	1
2	1	Exercício 1	100	1	1	500	1500	2000	50000	Zip	diff	-bB	100
5	1	Exercício 1	100	1	1	500	1500	2000	50000	Zip	diff	-bB	25
5	2	Exercício 2	100	1	1	500	1500	2000	50000	Zip	diff	-bB	25
5	3	Exercício 3	100	1	1	500	1500	2000	50000	Zip	diff	-bB	25
5	4	Exercício 4	100	1	1	500	1500	2000	50000	Zip	diff	-bB	25
3	1	Exercício 1 	100	0	0	500	1500	2000	50000	C	diff	-bB	34
3	2	Exercício 2	100	1	1	500	1500	2000	50000	Zip	diff	-bB	33
3	3	Exercício 3	100	1	1	500	1500	2000	50000	Zip	diff	-bB	33
4	1	Exercício 	100	1	1	500	1500	2000	50000	Zip	diff	-bB	100
\.


--
-- Data for Name: shj_queue; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_queue (id, submit_id, username, assignment, problem, type) FROM stdin;
\.


--
-- Name: shj_queue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sharifjudge
--

SELECT pg_catalog.setval('public.shj_queue_id_seq', 1227, true);


--
-- Data for Name: shj_scoreboard; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_scoreboard (assignment, scoreboard) FROM stdin;
\.


--
-- Data for Name: shj_sessions; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_sessions (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
\.


--
-- Data for Name: shj_settings; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_settings (shj_key, shj_value) FROM stdin;
submit_penalty	300
moss_userid	
timezone	America/Sao_Paulo
tester_path	/var/www/judge/pcs3616/tester
assignments_root	/var/www/judge/pcs3616/assignments
file_size_limit	3000
output_size_limit	1024
default_late_rule	/* \n * Put coefficient (from 100) in variable $coefficient.\n * You can use variables $extra_time and $delay.\n * $extra_time is the total extra time given to users\n * (in seconds) and $delay is number of seconds passed\n * from finish time (can be negative).\n *  In this example, $extra_time is 172800 (2 days):\n */\n\nif ($delay<=0)\n  // no delay\n  $coefficient = 100;\n\nelseif ($delay<=3600)\n  // delay less than 1 hour\n  $coefficient = ceil(100-((30*$delay)/3600));\n\nelseif ($delay<=86400)\n  // delay more than 1 hour and less than 1 day\n  $coefficient = 70;\n\nelseif (($delay-86400)<=3600)\n  // delay less than 1 hour in second day\n  $coefficient = ceil(70-((20*($delay-86400))/3600));\n\nelseif (($delay-86400)<=86400)\n  // delay more than 1 hour in second day\n  $coefficient = 50;\n\nelseif ($delay > $extra_time)\n  // too late\n  $coefficient = 0;
enable_easysandbox	0
enable_c_shield	0
enable_cpp_shield	1
enable_py2_shield	1
enable_py3_shield	1
enable_java_policy	1
enable_log	1
final_grade	0
final_grade	0
enable_registration	0
enable_scoreboard	0
registration_code	0
mail_from	judge.pcs3111@gmail.com
mail_from_name	PCS 3616 - Judge
reset_password_mail	<p>\nVocê requisitou uma nova senha para a sua conta no Judge da disciplina PCS3616 em {SITE_URL}.\n</p>\n<p>\nPara alterar a sua senha, visite o link:\n</p>\n<p>\n<a href="{RESET_LINK}">Resetar senha</a>\n</p>\n<p>\nEste link é válido por {VALID_TIME}. Se você não quiser alterar a sua senha, apenas ignore este e-mail.\n</p>
add_user_mail	<p>\nOlá Aluno<br/>\nVocê foi registrado no Judge da disciplina PCS3616 em {SITE_URL} como {ROLE}.\n</p>\n<p>\nNome de usuário: {USERNAME}\n</p>\n<p>\nSenha: {PASSWORD}\n</p>
results_per_page_all	0
results_per_page_final	0
week_start	0
queue_is_working	0
\.


--
-- Data for Name: shj_submissions; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_submissions (submit_id, username, assignment, problem, is_final, "time", status, pre_score, coefficient, file_name, main_file_name, file_type) FROM stdin;
43	10705613	2	1	1	2020-01-20 16:53:01	Resultado	0	100	lab1-atv3-10705613-43	lab1-atv3-10705613	zip
54	miguel	3	1	0	2020-01-15 15:24:52	SCORE	0	100	fatorial-54	fatorial	c
87	10770263	3	1	1	2020-01-15 15:59:32	SCORE	10000	100	fatorial-87	fatorial	c
38	10770200	4	1	1	2020-01-22 15:00:36	Resultado	0	100	lab2-atv4-10770200-38	lab2-atv4-10770200	zip
44	10773968	2	1	1	2020-01-20 16:53:52	Resultado	0	100	lab1-atv3-10773968-44	lab1-atv3-10773968	zip
46	9784439	2	1	0	2020-01-22 15:03:00	Resultado	0	100	lab2-atc3-9784439-46	lab2-atc3-9784439	zip
384	5456321	1	7	1	2020-01-22 17:09:02	Resultado	0	96	2_7-384	2_7	zip
42	8572921	4	1	1	2020-01-22 15:06:34	Resultado	0	100	regex-42	regex	zip
379	5456321	1	1	0	2020-01-22 17:07:58	Resultado	0	97	2_1-379	2_1	zip
321	10705613	1	5	1	2020-01-20 15:38:35	Resultado	0	100	2_5-321	2_5	zip
347	9833173	1	4	1	2020-01-22 15:16:21	Resultado	0	100	lab1_atv2_4_9833173-347	lab1_atv2_4_9833173	zip
46	10333362	4	1	1	2020-01-22 15:43:48	Resultado	0	100	lab2-atv4-10333362-46	lab2-atv4-10333362	zip
378	10333251	1	7	1	2020-01-22 16:02:51	Resultado	0	100	lab1_atv2_7_10333251-378	lab1_atv2_7_10333251	zip
173	10770141	3	1	0	2020-01-22 15:44:47	SCORE	10000	100	lab2-atv3-10770141-173	lab2-atv3-10770141	c
138	9395032	1	1	0	2020-01-06 17:22:29	Resultado	0	100	Misterio-138	Misterio	zip
177	10706110	1	1	0	2020-01-08 16:16:57	Resultado	0	100	2_6-177	2_6	zip
174	10770141	3	3	1	2020-01-22 15:45:03	Resultado	0	100	lab2-atv3-10770141-174	lab2-atv3-10770141	zip
179	10706110	1	1	0	2020-01-08 16:17:03	Resultado	0	100	2_7-179	2_7	zip
175	10706110	1	1	0	2020-01-08 16:16:51	Resultado	0	100	2_5-175	2_5	zip
19	9833173	2	1	0	2020-01-08 17:18:45	Resultado	0	100	3-19	3	zip
173	10706110	1	4	0	2020-01-08 16:16:38	Resultado	0	100	2_4-173	2_4	zip
182	10770180	1	7	0	2020-01-08 16:17:28	Resultado	0	100	2_7-182	2_7	zip
268	9784439	1	1	0	2020-01-08 16:56:51	Resultado	0	100	2_6-268	2_6	zip
266	9784439	1	4	0	2020-01-08 16:56:23	Resultado	0	100	2_4-266	2_4	zip
269	9784439	1	7	0	2020-01-08 16:57:06	Resultado	0	100	2_7-269	2_7	zip
273	8572921	1	2	1	2020-01-08 17:03:45	Resultado	0	100	lab1_atv2_2_8572921-273	lab1_atv2_2_8572921	zip
279	10333205	1	3	1	2020-01-08 17:04:34	Resultado	0	100	lab1_atv2_3_10333205-279	lab1_atv2_3_10333205	zip
128	10336831	1	1	1	2020-01-06 17:15:55	Resultado	0	100	lab1_atv2_1_10336831-128	lab1_atv2_1_10336831	zip
131	10336831	1	4	1	2020-01-06 17:16:57	Resultado	0	100	lab1_atv2_4_10336831-131	lab1_atv2_4_10336831	zip
140	10394382	1	1	1	2020-01-06 17:24:57	Resultado	0	100	lab1_atv2_1_10394382-140	lab1_atv2_1_10394382	zip
141	10394382	1	2	1	2020-01-06 17:25:24	Resultado	0	100	lab1_atv2_2_10394382-141	lab1_atv2_2_10394382	zip
31	10336852	4	1	1	2020-01-20 15:27:40	Resultado	0	100	lab2-atv4-10336852-31	lab2-atv4-10336852	zip
32	10770162	4	1	1	2020-01-20 15:39:55	Resultado	0	100	regex-32	regex	zip
34	10705613	4	1	1	2020-01-20 15:52:56	Resultado	0	100	lab2-atv4-10705613-34	lab2-atv4-10705613	zip
37	10773968	4	1	1	2020-01-20 16:57:27	Resultado	0	100	lab2_atv4-10773968-37	lab2_atv4-10773968	zip
380	5456321	1	2	1	2020-01-22 17:08:13	Resultado	0	96	2_2-380	2_2	zip
357	9373372	1	2	1	2020-01-22 15:45:54	Resultado	0	100	lab1_atv2_2_9373372-357	lab1_atv2_2_9373372	zip
294	andrei	1	1	1	2020-01-20 15:15:58	Resultado	0	100	lab1_atv2_1_10333268-294	lab1_atv2_1_10333268	zip
309	10774142	1	2	1	2020-01-20 15:19:52	Resultado	0	100	lab1-atv2-10774142-309	lab1-atv2-10774142	zip
320	10705613	1	4	1	2020-01-20 15:33:22	Resultado	0	100	2_4-320	2_4	zip
331	9395032	1	6	1	2020-01-20 16:00:50	Resultado	0	100	2_6-331	2_6	zip
248	10770217	1	1	1	2020-01-08 16:50:07	Resultado	0	100	2_1-248	2_1	zip
41	10773374	1	1	1	2020-01-06 16:47:33	Resultado	0	100	2_1-41	2_1	zip
77	10773374	1	7	1	2020-01-06 16:51:20	Resultado	0	100	2_7-77	2_7	zip
93	9784439	3	1	1	2020-01-15 16:04:57	SCORE	10000	100	fatoril-93	fatoril	c
225	5051111	1	2	1	2020-01-08 16:46:02	Resultado	0	100	lab1_atv2_2_5051111-225	lab1_atv2_2_5051111	zip
20	10770217	2	1	0	2020-01-08 17:19:21	Resultado	0	100	lab1-atv3-10770217-20	lab1-atv3-10770217	zip
45	10773210	2	1	0	2020-01-22 15:00:47	Resultado	0	100	lab1-atv3-10773210-45	lab1-atv3-10773210	zip
56	9373372	2	1	1	2020-01-22 16:18:34	Resultado	0	100	lab1_atv3_9373372-56	lab1_atv3_9373372	zip
5	10687472	2	1	0	2020-01-06 16:59:15	Resultado	0	100	e21-5	e21	zip
29	5051111	2	1	0	2020-01-15 16:03:54	Resultado	0	100	lab1-atv3-5051111-29	lab1-atv3-5051111	zip
41	10770238	2	1	1	2020-01-20 16:22:25	Resultado	0	100	lab1_atv3_10770238-41	lab1_atv3_10770238	zip
4	miguel	5	1	0	2020-01-19 19:36:34	Resultado	0	100	mt_soma_errada-4	mt_soma_errada	zip
14	10333362	2	1	1	2020-01-08 17:08:52	Resultado	0	100	lab1-atv3-10333362-14	lab1-atv3-10333362	zip
23	9395004	2	1	1	2020-01-13 16:38:53	Resultado	0	100	lab1-atv3-9395004-23	lab1-atv3-9395004	zip
1	miguel	5	1	0	2020-01-18 20:41:25	Resultado	0	100	mt_soma-1	mt_soma	zip
35	10774782	2	1	1	2020-01-20 15:09:44	Resultado	0	100	lab1-atv3-10774782-35	lab1-atv3-10774782	zip
106	10770217	3	2	1	2020-01-15 16:14:59	Resultado	0	100	lab2_atv1_10770217-106	lab2_atv1_10770217	zip
28	10770238	3	2	1	2020-01-13 16:25:40	Resultado	0	100	lab2_atv2_10770238-28	lab2_atv2_10770238	zip
55	10770109	3	1	0	2020-01-15 15:27:24	SCORE	10000	100	fatorial-55	fatorial	c
3	10770238	3	1	1	2020-01-13 15:37:47	Resultado	0	100	fatorial-3	fatorial	zip
136	10772612	3	2	1	2020-01-15 16:45:24	Resultado	0	100	makefile-test-136	makefile-test	zip
40	10273988	3	1	1	2020-01-13 16:49:47	Resultado	0	100	lab2-atv3-10273988-40	lab2-atv3-10273988	zip
43	10770120	4	1	1	2020-01-22 15:16:41	Resultado	0	100	lab2-atv4-10770120-43	lab2-atv4-10770120	zip
178	9373372	3	1	0	2020-01-22 16:24:24	Compilation Error	0	100	fatorial-178	fatorial	c
21	10336831	3	1	1	2020-01-13 16:14:59	Resultado	0	100	fatorial-21	fatorial	zip
129	10773210	3	1	1	2020-01-15 16:34:35	SCORE	10000	100	fatorial-129	fatorial	c
182	9373372	3	1	1	2020-01-22 16:32:21	SCORE	0	100	fatorial-182	fatorial	c
91	10770200	3	1	0	2020-01-15 16:03:26	SCORE	3333	100	fatorial-91	fatorial	c
61	10770200	3	1	0	2020-01-15 15:33:26	SCORE	3333	100	fatorial-61	fatorial	c
44	10773968	3	2	1	2020-01-13 16:53:45	Resultado	0	100	lab2_atv2-10773968-44	lab2_atv2-10773968	zip
116	8041400	3	1	0	2020-01-15 16:21:06	SCORE	0	100	fatorial-116	fatorial	c
140	5051111	3	2	1	2020-01-15 16:58:27	Resultado	0	100	lab2-atv2-5051111-140	lab2-atv2-5051111	zip
39	10770162	2	1	1	2020-01-20 15:58:40	Resultado	0	100	clmystery-39	clmystery	zip
39	8572921	4	1	0	2020-01-22 15:01:33	Resultado	0	100	lab2-atv4-8572921-39	lab2-atv4-8572921	zip
381	5456321	1	3	1	2020-01-22 17:08:26	Resultado	0	96	2_3-381	2_3	zip
4	10773353	3	3	1	2020-01-13 15:53:14	Resultado	0	100	lab2-atv3-10773353-4	lab2-atv3-10773353	zip
348	9833173	1	5	1	2020-01-22 15:16:55	Resultado	0	100	lab1_atv2_5_9833173-348	lab1_atv2_5_9833173	zip
349	9833173	1	6	1	2020-01-22 15:17:12	Resultado	0	100	lab1_atv2_6_9833173-349	lab1_atv2_6_9833173	zip
358	9373372	1	3	1	2020-01-22 15:46:09	Resultado	0	100	lab1_atv2_3_9373372-358	lab1_atv2_3_9373372	zip
56	10770109	3	1	0	2020-01-15 15:30:02	SCORE	10000	100	fatorial-56	fatorial	c
22	10770093	3	1	1	2020-01-13 16:15:52	Resultado	0	100	fatorial-22	fatorial	zip
63	miguel	3	1	1	2020-01-15 15:35:09	SCORE	0	100	fatorial-63	fatorial	c
62	10333362	3	1	0	2020-01-15 15:33:31	Compilation Error	0	100	fatorial-62	fatorial	c
159	9344880	3	2	1	2020-01-20 16:29:13	Resultado	0	100	lab2-atv2-9344880-159	lab2-atv2-9344880	zip
76	10706110	3	3	1	2020-01-15 15:49:11	Resultado	0	100	lab2-atv3-10706110-76	lab2-atv3-10706110	zip
341	10274461	1	1	1	2020-01-20 16:59:19	Resultado	0	100	lab2-atv4-10274461-341	lab2-atv4-10274461	zip
29	10770093	3	2	1	2020-01-13 16:29:37	Resultado	0	100	makefile-test-29	makefile-test	zip
146	10774142	3	1	1	2020-01-20 15:12:14	SCORE	10000	100	lab2_atv1_10774142-146	lab2_atv1_10774142	c
295	andrei	1	2	1	2020-01-20 15:16:32	Resultado	0	100	lab1_atv2_2_10333268-295	lab1_atv2_2_10333268	zip
296	andrei	1	3	1	2020-01-20 15:16:55	Resultado	0	100	lab1_atv2_3_10333268-296	lab1_atv2_3_10333268	zip
310	10774142	1	3	1	2020-01-20 15:20:06	Resultado	0	100	lab1-atv3-10774142-310	lab1-atv3-10774142	zip
316	10705613	1	2	1	2020-01-20 15:29:14	Resultado	0	100	2_2-316	2_2	zip
332	9395032	1	7	1	2020-01-20 16:01:06	Resultado	0	100	2_7-332	2_7	zip
2	miguel	5	1	0	2020-01-18 21:59:05	Resultado	0	100	mt_soma-2	mt_soma	zip
226	10773210	1	7	1	2020-01-08 16:46:06	Resultado	0	100	lab1_atv2_7_10773210-226	lab1_atv2_7_10773210	zip
179	9373372	3	1	0	2020-01-22 16:25:52	SCORE	0	100	fatorial-179	fatorial	c
22	10773374	2	1	1	2020-01-13 16:03:08	Resultado	0	100	clmystery-22	clmystery	zip
27	10770141	2	1	0	2020-01-15 15:40:37	Resultado	0	100	lab1-atv3-10770141-27	lab1-atv3-10770141	zip
5	miguel	5	1	1	2020-01-19 19:38:44	Resultado	0	100	mt_soma-5	mt_soma	zip
240	7335100	1	4	1	2020-01-08 16:47:40	Resultado	0	100	2_4-240	2_4	zip
213	8041400	1	3	1	2020-01-08 16:28:42	Resultado	0	100	lab1_atv2_3_8041400-213	lab1_atv2_3_8041400	zip
33	10773096	4	1	1	2020-01-20 15:40:05	Resultado	0	100	lab2-atv4-10773096-33	lab2-atv4-10773096	zip
214	8041400	1	4	1	2020-01-08 16:29:20	Resultado	0	100	lab1_atv2_4_8041400-214	lab1_atv2_4_8041400	zip
216	8041400	1	6	1	2020-01-08 16:29:56	Resultado	0	100	lab1_atv2_6_8041400-216	lab1_atv2_6_8041400	zip
217	8041400	1	7	1	2020-01-08 16:30:15	Resultado	0	100	lab1_atv2_7_8041400-217	lab1_atv2_7_8041400	zip
158	10770200	1	3	1	2020-01-08 15:53:40	Resultado	0	100	lab1_atv2_3_10770200-158	lab1_atv2_3_10770200	zip
167	10770200	1	4	1	2020-01-08 16:15:06	Resultado	0	100	lab1_atv2_4_10770200-167	lab1_atv2_4_10770200	zip
8	10773116	4	1	1	2020-01-13 17:05:20	Resultado	0	100	lab2-atv4-10773116-8	lab2-atv4-10773116	zip
171	10770200	1	5	1	2020-01-08 16:16:13	Resultado	0	100	lab1_atv2_5_10770200-171	lab1_atv2_5_10770200	zip
254	10770217	1	4	1	2020-01-08 16:51:22	Resultado	0	100	2_4-254	2_4	zip
256	10770217	1	5	1	2020-01-08 16:51:39	Resultado	0	100	2_5-256	2_5	zip
154	10770263	1	1	1	2020-01-08 15:44:26	Resultado	0	100	lab1_atv2_1_10770263-154	lab1_atv2_1_10770263	zip
197	10772612	1	1	1	2020-01-08 16:24:26	Resultado	0	100	lav1_atv2_1_10772612-197	lav1_atv2_1_10772612	zip
382	5456321	1	4	1	2020-01-22 17:08:38	Resultado	0	96	2_4-382	2_4	zip
276	8572921	1	4	1	2020-01-08 17:04:16	Resultado	0	100	lab1_atv2_4_8572921-276	lab1_atv2_4_8572921	zip
40	10770217	4	1	1	2020-01-22 15:01:52	Resultado	0	100	lab2_atv4_10770217-40	lab2_atv4_10770217	zip
350	9833173	1	7	1	2020-01-22 15:17:28	Resultado	0	100	lab1_atv2_7_9833173-350	lab1_atv2_7_9833173	zip
37	9344880	1	2	1	2020-01-06 16:44:20	Resultado	0	100	lab1-atv2_2-9344880-37	lab1-atv2_2-9344880	zip
39	9344880	1	3	1	2020-01-06 16:46:18	Resultado	0	100	lab1-atv2_3-9344880-39	lab1-atv2_3-9344880	zip
48	9395004	1	2	1	2020-01-06 16:48:37	Resultado	0	100	lab1_atv2_2_9395004-48	lab1_atv2_2_9395004	zip
85	9395032	1	3	0	2020-01-06 16:56:24	Resultado	0	100	lab1_atv2_3_9395032-85	lab1_atv2_3_9395032	zip
8	jailson	1	1	1	2020-01-06 12:50:39	Resultado	0	100	2_1-8	2_1	zip
329	9395032	1	4	1	2020-01-20 16:00:16	Resultado	0	100	2_4-329	2_4	zip
3	miguel	5	1	0	2020-01-18 23:56:00	Resultado	0	100	mt_soma-3	mt_soma	zip
161	10770180	1	1	0	2020-01-08 16:07:38	Resultado	0	100	2_1-161	2_1	zip
249	9833173	1	1	0	2020-01-08 16:50:08	Resultado	0	100	2_1-249	2_1	zip
101	10687472	1	2	0	2020-01-06 17:00:40	Resultado	0	100	e22-101	e22	zip
149	10336831	3	2	1	2020-01-20 15:30:05	Resultado	0	100	lab2-atv2-10336831-149	lab2-atv2-10336831	zip
156	10394382	3	3	1	2020-01-20 16:01:09	Resultado	0	100	lab2-atv3-10394382-156	lab2-atv3-10394382	zip
153	9344880	3	1	1	2020-01-20 15:41:35	SCORE	10000	100	fatorial-153	fatorial	c
160	andrei	3	3	1	2020-01-20 16:34:54	Resultado	0	100	lab2_atv1_3_10333268-160	lab2_atv1_3_10333268	zip
141	10773374	3	3	1	2020-01-20 15:02:35	Resultado	0	100	lab2-atv3-10773374-141	lab2-atv3-10773374	zip
34	10774782	1	1	0	2020-01-06 16:39:00	Resultado	0	100	2_7-34	2_7	zip
118	10773096	1	3	0	2020-01-06 17:07:16	Resultado	0	100	lab1_atv2_3_10773096-118	lab1_atv2_3_10773096	zip
24	andrei	1	5	0	2020-01-06 16:36:50	Resultado	0	100	lab1_atv2_5_10333268-24	lab1_atv2_5_10333268	zip
10	10773353	1	1	0	2020-01-06 15:59:28	Resultado	0	100	lab1_atv2_1_10773353-10	lab1_atv2_1_10773353	zip
40	10773116	2	1	1	2020-01-20 15:58:52	Resultado	0	100	misterio-40	misterio	zip
180	9373372	3	1	0	2020-01-22 16:28:25	Compilation Error	0	100	fatorial-180	fatorial	c
20	9833173	4	1	0	2020-01-15 16:49:37	Resultado	0	100	lab2-atv4-9833173-20	lab2-atv4-9833173	zip
9	10773353	4	1	1	2020-01-13 17:05:20	Resultado	0	100	lab2-atv4-10773353-9	lab2-atv4-10773353	zip
181	9373372	3	1	0	2020-01-22 16:29:16	SCORE	0	100	fatorial-181	fatorial	c
41	9833173	4	1	1	2020-01-22 15:01:55	Resultado	0	100	lab2-atv4-9833173-41	lab2-atv4-9833173	zip
165	7335100	3	3	1	2020-01-22 15:18:41	Resultado	0	100	lab2-atv3-7335100-165	lab2-atv3-7335100	zip
2	10687472	4	1	0	2020-01-13 16:17:09	Resultado	0	100	lab2-atv4-10687472-2	lab2-atv4-10687472	cpp
4	10273988	4	1	1	2020-01-13 16:50:09	Resultado	0	100	lab2-atv4-10273988-4	lab2-atv4-10273988	zip
383	5456321	1	6	1	2020-01-22 17:08:51	Resultado	0	96	2_6-383	2_6	zip
13	10333205	4	1	1	2020-01-15 16:34:02	Resultado	0	100	lab2-atv4-10333205-13	lab2-atv4-10333205	zip
24	10333397	4	1	1	2020-01-15 16:55:14	Resultado	0	100	lab2-atv4-10333205-24	lab2-atv4-10333205	zip
17	10773353	1	1	1	2020-01-06 16:06:49	Resultado	0	100	lab1_atv2_1_10773353-17	lab1_atv2_1_10773353	zip
26	10774782	1	2	1	2020-01-06 16:37:14	Resultado	0	100	2_2-26	2_2	zip
28	10770109	4	1	1	2020-01-15 16:58:29	Resultado	0	100	lab2-atv4-10770109-28	lab2-atv4-10770109	zip
22	10770180	4	1	1	2020-01-15 16:51:07	Resultado	0	100	lab2-atv4-10770180-22	lab2-atv4-10770180	zip
365	10333397	1	1	1	2020-01-22 15:56:29	Resultado	0	100	lab1_atv2_1_10333397-365	lab1_atv2_1_10333397	zip
364	10333251	1	2	0	2020-01-22 15:54:37	Resultado	0	100	lab1_atv2_1_10333251-364	lab1_atv2_1_10333251	zip
12	10336852	1	3	1	2020-01-06 16:04:42	Resultado	0	100	lab1_atv2_3_10336852-12	lab1_atv2_3_10336852	zip
13	10336852	1	4	1	2020-01-06 16:04:49	Resultado	0	100	lab1_atv2_4_10336852-13	lab1_atv2_4_10336852	zip
14	10336852	1	5	1	2020-01-06 16:04:56	Resultado	0	100	lab1_atv2_5_10336852-14	lab1_atv2_5_10336852	zip
360	9373372	1	5	1	2020-01-22 15:46:43	Resultado	0	100	lab1_atv2_5_9373372-360	lab1_atv2_5_9373372	zip
15	10336852	1	6	1	2020-01-06 16:05:03	Resultado	0	100	lab1_atv2_6_10336852-15	lab1_atv2_6_10336852	zip
16	10336852	1	7	1	2020-01-06 16:05:17	Resultado	0	100	lab1_atv2_7_10336852-16	lab1_atv2_7_10336852	zip
52	10770120	2	1	1	2020-01-22 15:49:39	Resultado	0	100	lab1-atv3-10770120-52	lab1-atv3-10770120	zip
7	10394382	2	1	0	2020-01-06 17:20:37	Resultado	0	100	lab_atv3_10394382-7	lab_atv3_10394382	zip
21	10770141	2	1	0	2020-01-08 17:19:28	Resultado	0	100	lab1_atv3_10770141-21	lab1_atv3_10770141	zip
24	10274461	2	1	1	2020-01-13 16:54:23	Resultado	0	100	lab1-atv3-10274461-24	lab1-atv3-10274461	zip
16	10772612	2	1	1	2020-01-08 17:13:18	Resultado	0	100	lab1-atv3-10772612-16	lab1-atv3-10772612	zip
130	10772612	3	1	1	2020-01-15 16:35:07	SCORE	10000	100	fatorial-130	fatorial	c
94	10770200	3	1	0	2020-01-15 16:05:04	SCORE	3333	100	fatorial-94	fatorial	c
64	10333362	3	1	0	2020-01-15 15:35:17	SCORE	6666	100	fatorial-64	fatorial	c
100	10770200	3	1	0	2020-01-15 16:11:20	SCORE	0	100	fatorial-100	fatorial	c
99	10333362	3	1	0	2020-01-15 16:09:49	SCORE	6666	100	fatorial-99	fatorial	c
45	10274461	3	1	1	2020-01-13 16:55:57	Resultado	0	100	lab2-atv1_1-10274461-45	lab2-atv1_1-10274461	zip
11	9395004	3	1	1	2020-01-13 16:03:13	Resultado	0	100	lab2-atv1-9395004-11	lab2-atv1-9395004	zip
5	10773353	3	2	1	2020-01-13 15:54:03	Resultado	0	100	lab2-atv2-10773353-5	lab2-atv2-10773353	zip
19	10770217	4	1	0	2020-01-15 16:49:16	Resultado	0	100	lab2_atv4_10770217-19	lab2_atv4_10770217	zip
7	10394382	4	1	1	2020-01-13 17:00:28	Resultado	0	100	lab2-atv4-10394382-7	lab2-atv4-10394382	zip
18	9373372	4	1	0	2020-01-15 16:47:33	Resultado	0	100	lab2_atv4_9373372-18	lab2_atv4_9373372	zip
15	10706110	4	1	1	2020-01-15 16:35:48	Resultado	0	100	lab2-atv4-10706110-15	lab2-atv4-10706110	zip
52	10773210	4	1	1	2020-01-22 16:59:46	Resultado	0	100	atv4-lab-10773210-52	atv4-lab-10773210	zip
25	10770141	4	1	1	2020-01-15 16:57:14	Resultado	0	100	lab2-atv4-10770141-25	lab2-atv4-10770141	zip
166	10770263	3	3	1	2020-01-22 15:36:14	Resultado	0	100	lab2_atv3_10770263-166	lab2_atv3_10770263	zip
14	10333205	4	1	0	2020-01-15 16:34:16	Resultado	0	100	lab1-atv3-10333205-14	lab1-atv3-10333205	zip
17	10772612	4	1	1	2020-01-15 16:44:55	Resultado	0	100	lab2-atv4-10772612-17	lab2-atv4-10772612	zip
23	8041400	4	1	1	2020-01-15 16:53:00	Resultado	0	100	lab2-atv4-8041400-23	lab2-atv4-8041400	zip
3	10687472	4	1	0	2020-01-13 16:18:44	Resultado	0	100	lab2-atv4-10687472-3	lab2-atv4-10687472	zip
167	9373372	3	1	0	2020-01-22 15:37:18	SCORE	0	100	fatorial-167	fatorial	c
175	10773210	3	2	0	2020-01-22 15:50:56	Resultado	0	100	makefile-test-175	makefile-test	zip
10	9395004	4	1	1	2020-01-13 17:05:23	Resultado	0	100	lab2-atv4-9395004-10	lab2-atv4-9395004	zip
385	5456321	1	1	1	2020-01-22 17:09:39	Resultado	0	96	lab1-atv3-5456321-385	lab1-atv3-5456321	zip
342	10770263	1	7	1	2020-01-22 15:02:40	Resultado	0	100	lab1_atv2_7_10770263-342	lab1_atv2_7_10770263	zip
361	9373372	1	6	1	2020-01-22 15:46:58	Resultado	0	100	lab1_atv2_6_9373372-361	lab1_atv2_6_9373372	zip
29	10773374	4	1	1	2020-01-20 15:03:05	Resultado	0	100	lab2-atv4-10773374-29	lab2-atv4-10773374	zip
20	10773353	1	5	1	2020-01-06 16:32:25	Resultado	0	100	lab1_atv2_5_10773353-20	lab1_atv2_5_10773353	zip
56	10773374	1	2	1	2020-01-06 16:49:43	Resultado	0	100	2_2-56	2_2	zip
57	10773374	1	3	1	2020-01-06 16:49:54	Resultado	0	100	2_3-57	2_3	zip
36	9395032	4	1	1	2020-01-20 16:23:54	Resultado	0	100	regex-36	regex	zip
73	10773374	1	6	1	2020-01-06 16:51:08	Resultado	0	100	2_6-73	2_6	zip
27	andrei	1	4	0	2020-01-06 16:37:15	Resultado	0	100	lab1_atv2_4_10333268-27	lab1_atv2_4_10333268	zip
317	10705613	1	1	0	2020-01-20 15:30:59	Resultado	0	100	2_3-317	2_3	zip
50	10770141	2	1	1	2020-01-22 15:18:52	Resultado	0	100	lab1-atv3-10770141-50	lab1-atv3-10770141	zip
17	10706110	2	1	1	2020-01-08 17:15:18	Resultado	0	100	lav1-atv3-10706110-17	lav1-atv3-10706110	zip
33	8572921	2	1	1	2020-01-15 16:40:50	Resultado	0	100	lab1-atv3-8572921-33	lab1-atv3-8572921	zip
42	10774142	2	1	1	2020-01-20 16:31:16	Resultado	0	100	lab1-atv3-10774142-42	lab1-atv3-10774142	zip
35	10770238	3	3	1	2020-01-13 16:39:24	Resultado	0	100	lab2-atv3-10770238-35	lab2-atv3-10770238	zip
84	10770263	3	2	1	2020-01-15 15:54:01	Resultado	0	100	lab2-atv2-10770263-84	lab2-atv2-10770263	zip
65	10706110	3	1	0	2020-01-15 15:44:02	SCORE	6666	100	fatorial-65	fatorial	c
71	7335100	3	2	1	2020-01-15 15:48:01	Resultado	0	100	lab2-atv2-7335100-71	lab2-atv2-7335100	zip
1	10336852	3	1	1	2020-01-13 15:12:28	File Format Not Supported	0	100	fatorial-1	fatorial	zip
58	10770263	3	1	0	2020-01-15 15:32:14	SCORE	6666	100	fatorial-58	fatorial	c
109	10333397	3	2	1	2020-01-15 16:16:20	Resultado	0	100	lab2-atv2-10333397-109	lab2-atv2-10333397	zip
108	10770109	3	3	1	2020-01-15 16:15:55	Resultado	0	100	lab2-atv3-10770109-108	lab2-atv3-10770109	zip
78	10770180	3	1	1	2020-01-15 15:50:45	SCORE	10000	100	fatorial-78	fatorial	c
228	5051111	1	3	1	2020-01-08 16:46:38	Resultado	0	100	lab1_atv2_3_5051111-228	lab1_atv2_3_5051111	zip
230	5051111	1	4	1	2020-01-08 16:46:54	Resultado	0	100	lab1_atv2_4_5051111-230	lab1_atv2_4_5051111	zip
235	5051111	1	5	1	2020-01-08 16:47:20	Resultado	0	100	lab1_atv2_5_5051111-235	lab1_atv2_5_5051111	zip
237	5051111	1	6	1	2020-01-08 16:47:31	Resultado	0	100	lab1_atv2_6_5051111-237	lab1_atv2_6_5051111	zip
239	5051111	1	7	1	2020-01-08 16:47:40	Resultado	0	100	lab1_atv2_7_5051111-239	lab1_atv2_7_5051111	zip
236	7335100	1	3	1	2020-01-08 16:47:26	Resultado	0	100	2_3-236	2_3	zip
210	8041400	1	1	1	2020-01-08 16:26:57	Resultado	0	100	lab1_atv2_1_8041400-210	lab1_atv2_1_8041400	zip
139	10770141	3	3	0	2020-01-15 16:55:12	Resultado	0	100	lab2-atv4-10770141-139	lab2-atv4-10770141	zip
246	7335100	1	7	0	2020-01-08 16:48:09	Resultado	0	100	2_7-246	2_7	zip
58	5456321	2	1	1	2020-01-22 17:10:05	Resultado	0	95	lab1-atv3-5456321-58	lab1-atv3-5456321	zip
28	10773210	2	1	0	2020-01-15 15:57:32	Resultado	0	100	lab1-atv3-10773210-28	lab1-atv3-10773210	zip
14	10773374	3	1	0	2020-01-13 16:03:52	Resultado	0	100	fatorial-14	fatorial	zip
66	7335100	3	1	0	2020-01-15 15:46:07	Compilation Error	0	100	fatorial-66	fatorial	c
111	7335100	3	3	0	2020-01-15 16:19:04	Resultado	0	100	lab2-atv4-7335100-111	lab2-atv4-7335100	zip
51	10770263	2	1	1	2020-01-22 15:23:01	Resultado	0	100	lab1_atv3_10770263-51	lab1_atv3_10770263	zip
47	9784439	2	1	1	2020-01-22 15:03:59	Resultado	0	100	Lab1-atv3-9784439-47	Lab1-atv3-9784439	zip
72	10706110	3	2	0	2020-01-15 15:48:06	Resultado	0	100	lab2-atv2-10706110-72	lab2-atv2-10706110	zip
12	8041400	2	1	1	2020-01-08 16:30:31	Resultado	0	100	lab1-atv3-8041400-12	lab1-atv3-8041400	zip
1	jailson	2	1	0	2020-01-06 12:57:15	Resultado	0	100	clmystery-1	clmystery	zip
80	10770217	3	1	1	2020-01-15 15:51:19	SCORE	10000	100	fatorial-80	fatorial	c
59	10770109	3	1	1	2020-01-15 15:32:14	SCORE	10000	100	fatorial-59	fatorial	c
10	10773116	2	1	0	2020-01-06 17:32:57	Resultado	0	100	misterio-10	misterio	zip
9	10394382	2	1	1	2020-01-06 17:27:17	Resultado	0	100	lab_atv3_10394382-9	lab_atv3_10394382	zip
43	10773968	3	2	0	2020-01-13 16:51:25	Resultado	0	100	lab2_atv2-10773968-43	lab2_atv2-10773968	zip
16	10773374	3	2	1	2020-01-13 16:05:58	Resultado	0	100	lab2-atv2-10773374-16	lab2-atv2-10773374	zip
32	10333251	2	1	1	2020-01-15 16:39:55	Resultado	0	100	lab1-atv3-10333251-32	lab1-atv3-10333251	zip
11	10687472	2	1	1	2020-01-06 17:39:17	Resultado	0	100	commandlinemystery-11	commandlinemystery	zip
36	10336852	2	1	1	2020-01-20 15:25:39	Resultado	0	100	lab1-atv3-10336852-36	lab1-atv3-10336852	zip
37	10773096	2	1	1	2020-01-20 15:35:48	Resultado	0	100	lab1-atv3-10773096-37	lab1-atv3-10773096	zip
12	7335100	4	1	0	2020-01-15 16:24:53	Resultado	0	100	lab2-atv4-7335100-12	lab2-atv4-7335100	zip
26	10333251	4	1	1	2020-01-15 16:57:32	Resultado	0	100	lab2-atv4-10333251-26	lab2-atv4-10333251	zip
11	10770238	4	1	1	2020-01-13 17:06:26	Resultado	0	100	lab2-atv4-10770238-11	lab2-atv4-10770238	zip
21	10770263	4	1	1	2020-01-15 16:50:17	Resultado	0	100	lab2-atv4-10770263-21	lab2-atv4-10770263	zip
16	7335100	4	1	1	2020-01-15 16:40:21	Resultado	0	100	lab2-atv4-7335100-16	lab2-atv4-7335100	zip
47	10770162	3	3	0	2020-01-13 17:01:34	Resultado	0	100	makefile2-47	makefile2	zip
27	10333362	4	1	0	2020-01-15 16:58:01	Resultado	0	100	lab2-atv4-10333362-27	lab2-atv4-10333362	zip
142	10394382	1	3	1	2020-01-06 17:25:56	Resultado	0	100	lab1_atv2_3_10394382-142	lab1_atv2_3_10394382	zip
143	10394382	1	4	1	2020-01-06 17:26:13	Resultado	0	100	lab1_atv2_4_10394382-143	lab1_atv2_4_10394382	zip
146	10394382	1	7	1	2020-01-06 17:26:55	Resultado	0	100	lab1_atv2_7_10394382-146	lab1_atv2_7_10394382	zip
6	10336831	4	1	1	2020-01-13 16:59:44	Resultado	0	100	lab2-atv4-10336831-6	lab2-atv4-10336831	zip
172	10706110	1	3	1	2020-01-08 16:16:28	Resultado	0	100	2_3-172	2_3	zip
181	10706110	1	4	1	2020-01-08 16:17:25	Resultado	0	100	2_4-181	2_4	zip
1	10336852	4	1	0	2020-01-13 16:06:34	Resultado	0	100	lab2-atv4-10336852-1	lab2-atv4-10336852	cpp
5	10687472	4	1	1	2020-01-13 16:53:38	Resultado	0	100	lab2-atv4-10687472-5	lab2-atv4-10687472	zip
183	10706110	1	5	1	2020-01-08 16:17:38	Resultado	0	100	2_5-183	2_5	zip
162	10770109	1	4	1	2020-01-08 16:08:54	Resultado	0	100	lab1_atv2_4_10770109-162	lab1_atv2_4_10770109	zip
163	10770109	1	5	1	2020-01-08 16:09:05	Resultado	0	100	lab1_atv2_5_10770109-163	lab1_atv2_5_10770109	zip
193	10770120	1	1	1	2020-01-08 16:23:52	Resultado	0	100	lab1_atv2_1_10770120-193	lab1_atv2_1_10770120	zip
231	10770141	1	2	1	2020-01-08 16:46:57	Resultado	0	100	lab1_atv2_2_10770141-231	lab1_atv2_2_10770141	zip
247	10770141	1	7	0	2020-01-08 16:48:13	Resultado	0	100	lab1_atv2_7_10770141-247	lab1_atv2_7_10770141	zip
32	10774782	1	1	0	2020-01-06 16:38:43	Resultado	0	100	2_5-32	2_5	zip
188	10770180	1	3	1	2020-01-08 16:21:16	Resultado	0	100	lab1_atv2_3_10770180-188	lab1_atv2_3_10770180	zip
192	10770180	1	7	1	2020-01-08 16:21:57	Resultado	0	100	lab1_atv2_7_10770180-192	lab1_atv2_7_10770180	zip
212	8041400	1	2	1	2020-01-08 16:28:11	Resultado	0	100	lab1_atv2_2_8041400-212	lab1_atv2_2_8041400	zip
105	10687472	1	1	0	2020-01-06 17:01:36	Resultado	0	100	e21-105	e21	zip
263	9784439	1	1	0	2020-01-08 16:54:57	Resultado	0	100	2_1-263	2_1	zip
275	8572921	1	1	0	2020-01-08 17:04:02	Resultado	0	100	lab1_atv2_3_8572921-275	lab1_atv2_3_8572921	zip
170	10770141	3	3	0	2020-01-22 15:39:29	Resultado	0	100	lab1_atv2_3_10770141-170	lab1_atv2_3_10770141	zip
106	10687472	1	2	0	2020-01-06 17:01:52	Resultado	0	100	e22-106	e22	zip
95	10274461	1	4	0	2020-01-06 16:59:02	Resultado	0	100	lab1_atv2_4_10274461-95	lab1_atv2_4_10274461	zip
351	9373372	1	1	0	2020-01-22 15:25:22	Resultado	0	100	lab1_atv2_1_9373372-351	lab1_atv2_1_9373372	zip
359	9373372	1	4	1	2020-01-22 15:46:27	Resultado	0	100	lab1_atv2_4_9373372-359	lab1_atv2_4_9373372	zip
362	9373372	1	7	1	2020-01-22 15:47:12	Resultado	0	100	lab1_atv2_7_9373372-362	lab1_atv2_7_9373372	zip
96	10274461	1	5	0	2020-01-06 16:59:20	Resultado	0	100	lab1_atv2_5_10274461-96	lab1_atv2_5_10274461	zip
280	10333205	1	4	1	2020-01-08 17:04:50	Resultado	0	100	lab1_atv2_4_10333205-280	lab1_atv2_4_10333205	zip
286	10333205	1	7	1	2020-01-08 17:05:35	Resultado	0	100	lab1_atv2_7_10333205-286	lab1_atv2_7_10333205	zip
22	andrei	1	2	0	2020-01-06 16:35:46	Resultado	0	100	lab1_atv2_2_10333268-22	lab1_atv2_2_10333268	zip
48	10773210	2	1	1	2020-01-22 15:05:04	Resultado	0	100	clmystery-48	clmystery	zip
34	10773353	2	1	1	2020-01-20 15:06:58	Resultado	0	100	lab1-atv3-10773353-34	lab1-atv3-10773353	zip
13	10770180	2	1	1	2020-01-08 17:08:33	Resultado	0	100	clmystery-13	clmystery	zip
26	10770200	2	1	1	2020-01-15 14:45:15	Resultado	0	100	lab1_atv3_10770200-26	lab1_atv3_10770200	zip
30	5051111	2	1	1	2020-01-15 16:04:53	Resultado	0	100	lab1-atv3-5051111-30	lab1-atv3-5051111	zip
18	7335100	2	1	1	2020-01-08 17:17:53	Resultado	0	100	lab1-atv2-7335100-18	lab1-atv2-7335100	zip
2	10773353	3	1	1	2020-01-13 15:36:53	Resultado	0	100	lab2-atv1-10773353-2	lab2-atv1-10773353	zip
81	8041400	3	1	0	2020-01-15 15:52:23	SCORE	0	100	lab2-atv1-8041400-81	lab2-atv1-8041400	c
67	10770141	3	1	0	2020-01-15 15:47:03	SCORE	6666	100	fatorial-67	fatorial	c
17	10773116	3	1	1	2020-01-13 16:10:14	Resultado	0	100	lab2-atv1-10773116-17	lab2-atv1-10773116	zip
60	8041400	3	1	0	2020-01-15 15:32:21	SCORE	0	100	lab2-atv4-8041400-60	lab2-atv4-8041400	c
18	10773116	3	2	1	2020-01-13 16:10:30	Resultado	0	100	lab2-atv2-10773116-18	lab2-atv2-10773116	zip
79	10770141	3	1	0	2020-01-15 15:51:13	SCORE	6666	100	fatorial-79	fatorial	c
97	10770200	3	1	0	2020-01-15 16:08:17	SCORE	3333	100	fatorial-97	fatorial	c
74	7335100	3	3	0	2020-01-15 15:48:15	Resultado	0	100	lab2-atv3-7335100-74	lab2-atv3-7335100	zip
150	10773096	3	1	1	2020-01-20 15:36:44	SCORE	10000	100	fatorial-150	fatorial	c
157	10336831	3	3	1	2020-01-20 16:01:18	Resultado	0	100	lab2-atv3-10336831-157	lab2-atv3-10336831	zip
8	10336852	3	2	1	2020-01-13 15:58:16	Resultado	0	100	lab2-atv2-10336852-8	lab2-atv2-10336852	zip
85	10770180	3	2	1	2020-01-15 15:57:43	Resultado	0	100	lab2-atv2-10770180-85	lab2-atv2-10770180	zip
25	10774782	1	1	0	2020-01-06 16:36:58	Resultado	0	100	2_1-25	2_1	zip
195	10770200	1	7	1	2020-01-08 16:24:11	Resultado	0	100	lab1_atv2_7_10770200-195	lab1_atv2_7_10770200	zip
196	10770263	1	3	1	2020-01-08 16:24:26	Resultado	0	100	lab1_atv2_3_10770263-196	lab1_atv2_3_10770263	zip
200	10770263	1	5	1	2020-01-08 16:24:53	Resultado	0	100	lab1_atv2_5_10770263-200	lab1_atv2_5_10770263	zip
114	10773096	1	1	1	2020-01-06 17:06:08	Resultado	0	100	lab1_atv2_1_10773096-114	lab1_atv2_1_10773096	zip
221	10773210	1	4	1	2020-01-08 16:41:24	Resultado	0	100	lab1_atv2_4_10773210-221	lab1_atv2_4_10773210	zip
18	10773353	1	2	1	2020-01-06 16:13:12	Resultado	0	100	lab1_atv2_2_10773353-18	lab1_atv2_2_10773353	zip
314	10774142	1	7	1	2020-01-20 15:20:52	Resultado	0	100	lab1-atv7-10774142-314	lab1-atv7-10774142	zip
333	10274461	1	1	0	2020-01-20 16:08:25	Resultado	0	100	lab1_atv2_1_10274461-333	lab1_atv2_1_10274461	zip
319	10705613	1	3	1	2020-01-20 15:31:55	Resultado	0	100	2_3-319	2_3	zip
323	10705613	1	7	1	2020-01-20 15:43:35	Resultado	0	100	2_7-323	2_7	zip
327	9395032	1	2	1	2020-01-20 15:59:39	Resultado	0	100	2_2-327	2_2	zip
337	10274461	1	5	1	2020-01-20 16:09:30	Resultado	0	100	lab1_atv2_5_10274461-337	lab1_atv2_5_10274461	zip
160	10770109	1	4	0	2020-01-08 16:01:41	Resultado	0	100	lab1_atv2_4_10770109-160	lab1_atv2_4_10770109	zip
23	andrei	1	3	0	2020-01-06 16:36:06	Resultado	0	100	lab1_atv2_3_10333268-23	lab1_atv2_3_10333268	zip
274	10333205	1	1	1	2020-01-08 17:03:51	Resultado	0	100	lab1_atv2_1_10333205-274	lab1_atv2_1_10333205	zip
281	10333205	1	5	1	2020-01-08 17:05:11	Resultado	0	100	lab1_atv2_5_10333205-281	lab1_atv2_5_10333205	zip
284	10333205	1	6	1	2020-01-08 17:05:23	Resultado	0	100	lab1_atv2_6_10333205-284	lab1_atv2_6_10333205	zip
129	10336831	1	2	1	2020-01-06 17:16:26	Resultado	0	100	lab1_atv2_2_10336831-129	lab1_atv2_2_10336831	zip
130	10336831	1	3	1	2020-01-06 17:16:40	Resultado	0	100	lab1_atv2_3_10336831-130	lab1_atv2_3_10336831	zip
194	10770109	1	7	1	2020-01-08 16:24:06	Resultado	0	100	lab1_atv2_7_10770109-194	lab1_atv2_7_10770109	zip
366	10333397	1	2	1	2020-01-22 15:56:51	Resultado	0	100	lab1_atv2_2_10333397-366	lab1_atv2_2_10333397	zip
363	10333251	1	1	0	2020-01-22 15:54:25	Resultado	0	100	lab1_atv1_1_10333251-363	lab1_atv1_1_10333251	zip
164	10770109	1	6	1	2020-01-08 16:13:59	Resultado	0	100	lab1_atv2_6_10770109-164	lab1_atv2_6_10770109	zip
238	10770141	1	4	1	2020-01-08 16:47:34	Resultado	0	100	lab1_atv2_4_10770141-238	lab1_atv2_4_10770141	zip
155	10770200	1	2	1	2020-01-08 15:44:30	Resultado	0	100	lab1_atv2_2_10770200-155	lab1_atv2_2_10770200	zip
306	10687472	1	6	1	2020-01-20 15:19:32	Resultado	0	100	2_6-306	2_6	zip
203	10770263	1	6	1	2020-01-08 16:25:06	Resultado	0	100	lab1_atv2_6_10770263-203	lab1_atv2_6_10770263	zip
201	10772612	1	3	1	2020-01-08 16:24:55	Resultado	0	100	lav1_atv2_3_10772612-201	lav1_atv2_3_10772612	zip
302	10687472	1	2	1	2020-01-20 15:18:40	Resultado	0	100	2_2-302	2_2	zip
303	10687472	1	3	1	2020-01-20 15:18:54	Resultado	0	100	2_3-303	2_3	zip
9	10336852	1	1	1	2020-01-06 15:56:11	Resultado	0	100	lab1_atv2_1_10336852-9	lab1_atv2_1_10336852	zip
184	10706110	1	6	1	2020-01-08 16:17:50	Resultado	0	100	2_6-184	2_6	zip
353	10333251	1	1	0	2020-01-22 15:33:48	Resultado	0	100	lab1-atv1-10333251-353	lab1-atv1-10333251	zip
159	10770109	1	3	1	2020-01-08 15:55:26	Resultado	0	100	lab1_atv2_3_10770109-159	lab1_atv2_3_10770109	zip
367	10333397	1	3	1	2020-01-22 15:57:01	Resultado	0	100	lab1_atv2_3_10333397-367	lab1_atv2_3_10333397	zip
108	10687472	1	4	0	2020-01-06 17:02:22	Resultado	0	100	e24-108	e24	zip
304	10687472	1	4	1	2020-01-20 15:19:07	Resultado	0	100	2_4-304	2_4	zip
305	10687472	1	5	1	2020-01-20 15:19:20	Resultado	0	100	2_5-305	2_5	zip
352	9373372	1	1	0	2020-01-22 15:26:51	Resultado	0	100	lab2_atv4_9373372-352	lab2_atv4_9373372	zip
151	10770109	1	1	0	2020-01-08 15:40:50	Resultado	0	100	lab1_atv2_1_10770109-151	lab1_atv2_1_10770109	zip
300	andrei	1	7	1	2020-01-20 15:18:15	Resultado	0	100	lab1_atv2_7_10333268-300	lab1_atv2_7_10333268	zip
315	10705613	1	1	0	2020-01-20 15:26:19	Resultado	0	100	2_1-315	2_1	zip
324	10705613	1	1	0	2020-01-20 15:51:24	Resultado	0	100	lab2-atv4-10705613-324	lab2-atv4-10705613	zip
328	9395032	1	3	1	2020-01-20 15:59:58	Resultado	0	100	2_3-328	2_3	zip
234	10770141	1	3	1	2020-01-08 16:47:18	Resultado	0	100	lab1_atv2_3_10770141-234	lab1_atv2_3_10770141	zip
125	10773968	1	5	1	2020-01-06 17:08:15	Resultado	0	100	lab1_atv2_5_10773968-125	lab1_atv2_5_10773968	zip
245	10770141	1	6	1	2020-01-08 16:48:02	Resultado	0	100	lab1_atv2_6_10770141-245	lab1_atv2_6_10770141	zip
52	10770162	1	1	1	2020-01-06 16:49:07	Resultado	0	100	2_1-52	2_1	zip
80	10770162	1	6	1	2020-01-06 16:51:39	Resultado	0	100	2_6-80	2_6	zip
189	10770180	1	4	1	2020-01-08 16:21:29	Resultado	0	100	lab1_atv2_4_10770180-189	lab1_atv2_4_10770180	zip
152	10770200	1	1	1	2020-01-08 15:42:31	Resultado	0	100	lab1_atv2_1_10770200-152	lab1_atv2_1_10770200	zip
176	10770200	1	6	1	2020-01-08 16:16:56	Resultado	0	100	lab1_atv2_6_10770200-176	lab1_atv2_6_10770200	zip
258	10770217	1	6	1	2020-01-08 16:51:53	Resultado	0	100	2_6-258	2_6	zip
156	10770263	1	2	1	2020-01-08 15:45:20	Resultado	0	100	lab1_atv2_2_10770263-156	lab1_atv2_2_10770263	zip
198	10770263	1	4	1	2020-01-08 16:24:41	Resultado	0	100	lab1_atv2_4_10770263-198	lab1_atv2_4_10770263	zip
199	10772612	1	2	1	2020-01-08 16:24:47	Resultado	0	100	lav1_atv2_2_10772612-199	lav1_atv2_2_10772612	zip
47	10773116	1	2	1	2020-01-06 16:48:27	Resultado	0	100	2_2-47	2_2	zip
218	10773210	1	1	1	2020-01-08 16:38:00	Resultado	0	100	lab1_atv2_1_10773210-218	lab1_atv2_1_10773210	zip
110	10687472	1	6	0	2020-01-06 17:02:43	Resultado	0	100	e26-110	e26	zip
113	10394382	1	1	0	2020-01-06 17:05:36	Resultado	0	100	lab_atv2_10394382-113	lab_atv2_10394382	zip
91	10774142	1	1	0	2020-01-06 16:57:35	Resultado	0	100	lab1_atv2_1_10774142-91	lab1_atv2_1_10774142	zip
38	10770093	2	1	1	2020-01-20 15:37:18	Resultado	0	100	clmystery-38	clmystery	zip
162	9784439	3	1	0	2020-01-22 15:07:57	SCORE	10000	100	lab2-atc3-9784439-162	lab2-atc3-9784439	c
311	10774142	1	4	1	2020-01-20 15:20:17	Resultado	0	100	lab1-atv4-10774142-311	lab1-atv4-10774142	zip
168	10770180	1	2	0	2020-01-08 16:15:42	Resultado	0	100	2_2-168	2_2	zip
174	10770180	1	4	0	2020-01-08 16:16:45	Resultado	0	100	2_4-174	2_4	zip
229	7335100	1	1	0	2020-01-08 16:46:44	Resultado	0	100	2_1-229	2_1	zip
264	9784439	1	2	0	2020-01-08 16:55:42	Resultado	0	100	2_2-264	2_2	zip
111	10687472	1	7	0	2020-01-06 17:02:51	Resultado	0	100	e27-111	e27	zip
60	10770093	1	2	1	2020-01-06 16:50:15	Resultado	0	100	2_2-60	2_2	zip
64	10770093	1	3	1	2020-01-06 16:50:29	Resultado	0	100	2_3-64	2_3	zip
66	10770093	1	4	1	2020-01-06 16:50:43	Resultado	0	100	2_4-66	2_4	zip
71	10770093	1	5	1	2020-01-06 16:51:02	Resultado	0	100	2_5-71	2_5	zip
76	10770093	1	6	1	2020-01-06 16:51:13	Resultado	0	100	2_6-76	2_6	zip
79	10770093	1	7	1	2020-01-06 16:51:33	Resultado	0	100	2_7-79	2_7	zip
227	10770141	1	1	1	2020-01-08 16:46:23	Resultado	0	100	lab1_atv2_1_10770141-227	lab1_atv2_1_10770141	zip
241	10770141	1	5	1	2020-01-08 16:47:49	Resultado	0	100	lab1_atv2_5_10770141-241	lab1_atv2_5_10770141	zip
72	10770162	1	5	1	2020-01-06 16:51:05	Resultado	0	100	2_5-72	2_5	zip
81	10770162	1	7	1	2020-01-06 16:52:10	Resultado	0	100	2_7-81	2_7	zip
250	10770217	1	2	1	2020-01-08 16:50:43	Resultado	0	100	2_2-250	2_2	zip
252	10770217	1	3	1	2020-01-08 16:51:06	Resultado	0	100	2_3-252	2_3	zip
253	9833173	1	2	0	2020-01-08 16:51:20	Resultado	0	100	2_2-253	2_2	zip
255	9833173	1	3	0	2020-01-08 16:51:32	Resultado	0	100	2_3-255	2_3	zip
169	10770180	1	3	0	2020-01-08 16:16:08	Resultado	0	100	2_3-169	2_3	zip
38	10770238	1	1	1	2020-01-06 16:44:25	Resultado	0	100	lab1_atv2_1_10770238-38	lab1_atv2_1_10770238	zip
204	10772612	1	5	1	2020-01-08 16:25:18	Resultado	0	100	lav1_atv2_5_10772612-204	lav1_atv2_5_10772612	zip
209	10772612	1	7	1	2020-01-08 16:26:02	Resultado	0	100	lav1_atv2_7_10772612-209	lav1_atv2_7_10772612	zip
120	10773096	1	4	1	2020-01-06 17:07:29	Resultado	0	100	lab1_atv2_4_10773096-120	lab1_atv2_4_10773096	zip
121	10773096	1	5	1	2020-01-06 17:07:45	Resultado	0	100	lab1_atv2_5_10773096-121	lab1_atv2_5_10773096	zip
123	10773096	1	6	1	2020-01-06 17:07:56	Resultado	0	100	lab1_atv2_6_10773096-123	lab1_atv2_6_10773096	zip
44	10773116	1	1	1	2020-01-06 16:48:08	Resultado	0	100	2_1-44	2_1	zip
49	10773116	1	3	1	2020-01-06 16:48:42	Resultado	0	100	2_3-49	2_3	zip
50	10773116	1	4	1	2020-01-06 16:48:51	Resultado	0	100	2_4-50	2_4	zip
51	10773116	1	5	1	2020-01-06 16:49:03	Resultado	0	100	2_5-51	2_5	zip
54	10773116	1	6	1	2020-01-06 16:49:19	Resultado	0	100	2_6-54	2_6	zip
55	10773116	1	7	1	2020-01-06 16:49:30	Resultado	0	100	2_7-55	2_7	zip
40	10773353	1	7	1	2020-01-06 16:46:29	Resultado	0	100	lab1_atv2_7_10773353-40	lab1_atv2_7_10773353	zip
63	10773374	1	4	1	2020-01-06 16:50:27	Resultado	0	100	2_4-63	2_4	zip
68	10773374	1	5	1	2020-01-06 16:50:50	Resultado	0	100	2_5-68	2_5	zip
119	10773968	1	2	1	2020-01-06 17:07:21	Resultado	0	100	lab1_atv2_2_10773968-119	lab1_atv2_2_10773968	zip
122	10773968	1	3	1	2020-01-06 17:07:45	Resultado	0	100	lab1_atv2_3_10773968-122	lab1_atv2_3_10773968	zip
124	10773968	1	4	1	2020-01-06 17:08:00	Resultado	0	100	lab1_atv2_4_10773968-124	lab1_atv2_4_10773968	zip
126	10773968	1	6	1	2020-01-06 17:08:31	Resultado	0	100	lab1_atv2_6_10773968-126	lab1_atv2_6_10773968	zip
135	10773968	1	7	1	2020-01-06 17:17:56	Resultado	0	100	lab1_atv2_7_10773968-135	lab1_atv2_7_10773968	zip
102	10774142	1	4	0	2020-01-06 17:00:46	Resultado	0	100	lab1_atv2_4_10774142-102	lab1_atv2_4_10774142	zip
104	10774142	1	6	0	2020-01-06 17:01:10	Resultado	0	100	lab1_atv2_6_10774142-104	lab1_atv2_6_10774142	zip
223	10773210	1	5	1	2020-01-08 16:45:38	Resultado	0	100	lab1_atv2_5_10773210-223	lab1_atv2_5_10773210	zip
147	10773353	1	3	1	2020-01-06 17:35:07	Resultado	0	100	lab1_atv2_3_10773353-147	lab1_atv2_3_10773353	zip
144	10774782	3	2	1	2020-01-20 15:08:13	Resultado	0	100	lab2-atv2-10774782-144	lab2-atv2-10774782	zip
150	10774782	1	1	1	2020-01-06 17:39:23	Resultado	0	100	lab1-atv3-10774782-150	lab1-atv3-10774782	zip
293	7335100	1	1	1	2020-01-08 17:17:23	Resultado	0	100	lab1-atv2-7335100-293	lab1-atv2-7335100	zip
233	7335100	1	2	1	2020-01-08 16:47:17	Resultado	0	100	2_2-233	2_2	zip
242	7335100	1	5	1	2020-01-08 16:47:52	Resultado	0	100	2_5-242	2_5	zip
244	7335100	1	6	1	2020-01-08 16:48:00	Resultado	0	100	2_6-244	2_6	zip
285	8572921	1	6	1	2020-01-08 17:05:34	Resultado	0	100	lab1_atv2_6_8572921-285	lab1_atv2_6_8572921	zip
278	8572921	1	3	1	2020-01-08 17:04:34	Resultado	0	100	lab1_atv2_3_8572921-278	lab1_atv2_3_8572921	zip
283	8572921	1	5	1	2020-01-08 17:05:18	Resultado	0	100	lab1_atv2_5_8572921-283	lab1_atv2_5_8572921	zip
288	8572921	1	7	1	2020-01-08 17:05:44	Resultado	0	100	lab1_atv2_7_8572921-288	lab1_atv2_7_8572921	zip
139	9344880	1	7	1	2020-01-06 17:23:36	Resultado	0	100	lab1-atv2_7-9344880-139	lab1-atv2_7-9344880	zip
282	9784439	1	2	1	2020-01-08 17:05:12	Resultado	0	100	lab1_atv2_2_9784439-282	lab1_atv2_2_9784439	zip
291	9784439	1	5	1	2020-01-08 17:06:26	Resultado	0	100	lab1_atv2_5_9784439-291	lab1_atv2_5_9784439	zip
292	9784439	1	7	1	2020-01-08 17:06:36	Resultado	0	100	lab1_atv2_7_9784439-292	lab1_atv2_7_9784439	zip
205	10770263	1	7	0	2020-01-08 16:25:19	Resultado	0	100	lab1_atv2_7_10770263-205	lab1_atv2_7_10770263	zip
307	10774142	1	1	1	2020-01-20 15:19:41	Resultado	0	100	lab1-atv1-10774142-307	lab1-atv1-10774142	zip
308	10687472	1	7	1	2020-01-20 15:19:45	Resultado	0	100	2_7-308	2_7	zip
325	10705613	1	1	1	2020-01-20 15:52:40	Resultado	0	100	lab1_atv2_1_10705613-325	lab1_atv2_1_10705613	zip
330	9395032	1	5	1	2020-01-20 16:00:31	Resultado	0	100	2_5-330	2_5	zip
338	10274461	1	6	1	2020-01-20 16:09:44	Resultado	0	100	lab1_atv2_6_10274461-338	lab1_atv2_6_10274461	zip
257	9833173	1	4	0	2020-01-08 16:51:47	Resultado	0	100	2_4-257	2_4	zip
2	jailson	2	1	1	2020-01-06 13:51:39	Resultado	0	100	nome-2	nome	zip
312	10774142	1	5	1	2020-01-20 15:20:28	Resultado	0	100	lab1-atv5-10774142-312	lab1-atv5-10774142	zip
318	10705613	1	1	0	2020-01-20 15:31:22	Resultado	0	100	2_1-318	2_1	zip
107	10687472	1	3	0	2020-01-06 17:02:11	Resultado	0	100	e23-107	e23	zip
109	10687472	1	5	0	2020-01-06 17:02:33	Resultado	0	100	e25-109	e25	zip
103	10774142	1	5	0	2020-01-06 17:00:58	Resultado	0	100	lab1_atv2_5_10774142-103	lab1_atv2_5_10774142	zip
376	10333251	1	5	1	2020-01-22 16:02:23	Resultado	0	100	lab1_atv2_5_10333251-376	lab1_atv2_5_10333251	zip
88	9395032	1	4	0	2020-01-06 16:57:05	Resultado	0	100	lab1_atv2_4_9395032-88	lab1_atv2_4_9395032	zip
165	10706110	1	1	1	2020-01-08 16:14:17	Resultado	0	100	2_1-165	2_1	zip
185	10706110	1	7	1	2020-01-08 16:18:04	Resultado	0	100	2_7-185	2_7	zip
153	10770109	1	1	1	2020-01-08 15:43:09	Resultado	0	100	lab1_atv2_1_10770109-153	lab1_atv2_1_10770109	zip
59	10770162	1	2	1	2020-01-06 16:50:10	Resultado	0	100	2_2-59	2_2	zip
259	9833173	1	5	0	2020-01-08 16:51:58	Resultado	0	100	2_5-259	2_5	zip
261	9833173	1	6	0	2020-01-08 16:52:09	Resultado	0	100	2_6-261	2_6	zip
262	9833173	1	7	0	2020-01-08 16:52:28	Resultado	0	100	2_7-262	2_7	zip
243	9373372	1	1	0	2020-01-08 16:47:52	Resultado	0	100	lab1_atv2_1_9373372-243	lab1_atv2_1_9373372	zip
368	10333397	1	4	1	2020-01-22 15:57:12	Resultado	0	100	lab1_atv2_4_10333397-368	lab1_atv2_4_10333397	zip
370	10333397	1	6	1	2020-01-22 15:57:38	Resultado	0	100	lab1_atv2_6_10333397-370	lab1_atv2_6_10333397	zip
354	10770141	1	7	1	2020-01-22 15:34:33	Resultado	0	100	lab1-atv2-7-10770141-354	lab1-atv2-7-10770141	zip
369	10333397	1	5	1	2020-01-22 15:57:23	Resultado	0	100	lab1_atv2_5_10333397-369	lab1_atv2_5_10333397	zip
336	10274461	1	4	1	2020-01-20 16:09:18	Resultado	0	100	lab1_atv2_4_10274461-336	lab1_atv2_4_10274461	zip
339	10274461	1	7	1	2020-01-20 16:09:59	Resultado	0	100	lab1_atv2_7_10274461-339	lab1_atv2_7_10274461	zip
207	10772612	1	5	0	2020-01-08 16:25:31	Resultado	0	100	lav1_atv2_7_10772612-207	lav1_atv2_7_10772612	zip
31	10774782	1	1	0	2020-01-06 16:38:35	Resultado	0	100	2_4-31	2_4	zip
21	andrei	1	1	0	2020-01-06 16:35:18	Resultado	0	100	lab1_atv2_1_10333268-21	lab1_atv2_1_10333268	zip
33	10774782	1	1	0	2020-01-06 16:38:52	Resultado	0	100	2_6-33	2_6	zip
45	10773374	1	1	0	2020-01-06 16:48:10	Resultado	0	100	2_3-45	2_3	zip
43	10773374	1	1	0	2020-01-06 16:47:53	Resultado	0	100	2_2-43	2_2	zip
1	jailson	1	1	0	2020-01-06 12:30:00	Resultado	0	100	2_1-1	2_1	zip
2	jailson	1	1	0	2020-01-06 12:34:02	Resultado	0	100	2_1-2	2_1	zip
356	9373372	1	1	1	2020-01-22 15:45:37	Resultado	0	100	lab1_atv2_1_9373372-356	lab1_atv2_1_9373372	zip
3	jailson	1	1	0	2020-01-06 12:35:14	Resultado	0	100	2_1-3	2_1	zip
4	jailson	1	1	0	2020-01-06 12:37:03	Resultado	0	100	2_1-4	2_1	zip
371	10333251	1	1	1	2020-01-22 15:57:43	Resultado	0	100	lab1_atv2_1_10333251-371	lab1_atv2_1_10333251	zip
5	jailson	1	1	0	2020-01-06 12:38:13	Resultado	0	100	2_1-5	2_1	zip
6	jailson	1	1	0	2020-01-06 12:42:16	Resultado	0	100	2_1-6	2_1	zip
7	jailson	1	1	0	2020-01-06 12:46:21	Resultado	0	100	2_1-7	2_1	zip
270	9784439	1	6	0	2020-01-08 16:57:29	Resultado	0	100	2_6-270	2_6	zip
251	9833173	1	1	0	2020-01-08 16:50:46	Resultado	0	100	2_1-251	2_1	zip
355	10333251	1	2	0	2020-01-22 15:38:32	Resultado	0	100	lab1-atv2-10333251-355	lab1-atv2-10333251	zip
372	10333397	1	7	1	2020-01-22 15:57:48	Resultado	0	100	lab1_atv2_7_10333397-372	lab1_atv2_7_10333397	zip
344	9833173	1	2	1	2020-01-22 15:15:43	Resultado	0	100	lab1_atv2_2_9833173-344	lab1_atv2_2_9833173	zip
373	10333251	1	2	1	2020-01-22 15:58:12	Resultado	0	100	lab1_atv2_2_10333251-373	lab1_atv2_2_10333251	zip
374	10333251	1	3	1	2020-01-22 16:00:48	Resultado	0	100	lab1_atv2_3_10333251-374	lab1_atv2_3_10333251	zip
375	10333251	1	4	1	2020-01-22 16:01:04	Resultado	0	100	lab1_atv2_4_10333251-375	lab1_atv2_4_10333251	zip
345	7335100	1	7	1	2020-01-22 15:15:55	Resultado	0	100	2_7-345	2_7	zip
163	9784439	3	3	0	2020-01-22 15:08:30	Resultado	0	100	lab2-atc3-9784439-163	lab2-atc3-9784439	zip
346	9833173	1	3	1	2020-01-22 15:16:04	Resultado	0	100	lab1_atv2_3_9833173-346	lab1_atv2_3_9833173	zip
377	10333251	1	6	1	2020-01-22 16:02:37	Resultado	0	100	lab1_atv2_6_10333251-377	lab1_atv2_6_10333251	zip
4	10687472	2	1	0	2020-01-06 16:19:46	Resultado	0	100	e21-4	e21	zip
44	9373372	4	1	0	2020-01-22 15:27:17	Resultado	0	100	lab2_atv4_9373372-44	lab2_atv4_9373372	zip
142	10774782	3	1	0	2020-01-20 15:02:43	SCORE	6666	100	fatorial-142	fatorial	c
23	10687472	3	1	1	2020-01-13 16:16:21	File Format Not Supported	0	100	lab2-atv1-10687472-23	lab2-atv1-10687472	zip
131	8572921	3	1	1	2020-01-15 16:40:05	SCORE	10000	100	fatorial-131	fatorial	c
158	andrei	3	2	1	2020-01-20 16:08:14	Resultado	0	100	lab2_atv1_1_10333268-158	lab2_atv1_1_10333268	zip
24	10687472	3	2	1	2020-01-13 16:16:34	Resultado	0	100	lab2-atv2-10787472-24	lab2-atv2-10787472	zip
89	10770109	3	2	1	2020-01-15 15:59:50	Resultado	0	100	lab2-atv2-10770109-89	lab2-atv2-10770109	zip
155	10770162	3	1	1	2020-01-20 15:46:19	SCORE	10000	100	fatorial-155	fatorial	c
161	10774142	3	2	1	2020-01-20 16:36:48	Resultado	0	100	lab2-atv2-10774142-161	lab2-atv2-10774142	zip
145	10774782	3	3	1	2020-01-20 15:08:51	Resultado	0	100	lab2-atv3-10774782-145	lab2-atv3-10774782	zip
46	10394382	3	2	0	2020-01-13 16:59:45	Resultado	0	100	lab2-atv4-10394382-46	lab2-atv4-10394382	zip
101	10770200	3	1	1	2020-01-15 16:13:34	SCORE	10000	100	fatorial-101	fatorial	c
88	10770200	3	2	1	2020-01-15 15:59:49	Resultado	0	100	lab2_atv2-10770200-88	lab2_atv2-10770200	zip
124	10333251	3	3	1	2020-01-15 16:29:00	Resultado	0	100	lab2-atv3-10333251-124	lab2-atv3-10333251	zip
25	10687472	3	3	1	2020-01-13 16:16:45	Resultado	0	100	lab2-atv3-10687472-25	lab2-atv3-10687472	zip
126	10333205	3	1	1	2020-01-15 16:31:15	SCORE	10000	100	fatorial-126	fatorial	c
104	10333251	3	1	1	2020-01-15 16:14:39	SCORE	10000	100	fatorial-104	fatorial	c
105	10333397	3	1	1	2020-01-15 16:14:56	SCORE	10000	100	fatorial-105	fatorial	c
127	10333205	3	2	1	2020-01-15 16:31:33	Resultado	0	100	lab2-atv2-10333205-127	lab2-atv2-10333205	zip
128	10333205	3	3	1	2020-01-15 16:33:30	Resultado	0	100	lab2-atv3-10333205-128	lab2-atv3-10333205	zip
110	10333251	3	2	1	2020-01-15 16:16:33	Resultado	0	100	lab2-atv2-10333251-110	lab2-atv2-10333251	zip
120	10333362	3	3	1	2020-01-15 16:26:09	Resultado	0	100	lab2-atv3-10333362-120	lab2-atv3-10333362	zip
125	10333397	3	3	1	2020-01-15 16:29:25	Resultado	0	100	lab2-atv3-10333397-125	lab2-atv3-10333397	zip
36	10705613	3	2	1	2020-01-13 16:41:04	Resultado	0	100	makefile-test-36	makefile-test	zip
39	10705613	3	3	1	2020-01-13 16:46:26	Resultado	0	100	lab2-atv3-10705613-39	lab2-atv3-10705613	zip
30	10770093	3	3	1	2020-01-13 16:30:55	Resultado	0	100	makefiledomoana-30	makefiledomoana	zip
137	10770120	3	2	1	2020-01-15 16:50:00	Resultado	0	100	lab2-atv2-10770120-137	lab2-atv2-10770120	zip
138	10770120	3	3	1	2020-01-15 16:50:26	Resultado	0	100	lab2-atv3-10770120-138	lab2-atv3-10770120	zip
38	10770162	3	2	1	2020-01-13 16:43:58	Resultado	0	100	makefile-test-38	makefile-test	zip
49	10770162	3	3	1	2020-01-13 17:03:15	Resultado	0	100	fatoriaaal2-49	fatoriaaal2	zip
117	10770200	3	3	1	2020-01-15 16:22:08	Resultado	0	100	lab2-atv3-10770200-117	lab2-atv3-10770200	zip
122	10770217	3	3	1	2020-01-15 16:28:00	Resultado	0	100	lab2_atv3_10770217-122	lab2_atv3_10770217	zip
134	10772612	3	3	1	2020-01-15 16:42:16	Resultado	0	100	lab2-atv3-10772612-134	lab2-atv3-10772612	zip
19	10773116	3	3	1	2020-01-13 16:10:46	Resultado	0	100	lab2-atv3-10773116-19	lab2-atv3-10773116	zip
53	10773968	3	3	1	2020-01-13 17:11:33	Resultado	0	100	lab2_atv3-10773968-53	lab2_atv3-10773968	zip
119	5051111	3	1	1	2020-01-15 16:25:58	SCORE	10000	100	fatorial-119	fatorial	c
70	7335100	3	1	1	2020-01-15 15:47:47	SCORE	10000	100	fatorial-70	fatorial	c
118	8041400	3	1	1	2020-01-15 16:24:10	SCORE	10000	100	fatorial-118	fatorial	c
114	8041400	3	2	1	2020-01-15 16:20:12	Resultado	0	100	lab2-atv2-8041400-114	lab2-atv2-8041400	zip
115	8041400	3	3	1	2020-01-15 16:20:23	Resultado	0	100	lab2-atv3-8041400-115	lab2-atv3-8041400	zip
132	8572921	3	2	1	2020-01-15 16:40:19	Resultado	0	100	lab2-atv2-8572921-132	lab2-atv2-8572921	zip
133	8572921	3	3	1	2020-01-15 16:40:34	Resultado	0	100	lab2-atv3-8572921-133	lab2-atv3-8572921	zip
51	9345234	3	3	1	2020-01-13 17:09:19	Resultado	0	100	lab2-atv3-9345234-51	lab2-atv3-9345234	zip
12	9395004	3	2	1	2020-01-13 16:03:29	Resultado	0	100	lab2-atv2-9395004-12	lab2-atv2-9395004	zip
65	10770162	1	3	1	2020-01-06 16:50:34	Resultado	0	100	2_3-65	2_3	zip
164	9784439	3	3	1	2020-01-22 15:10:27	Resultado	0	100	lab2-atc3-9784439-164	lab2-atc3-9784439	zip
121	7335100	3	3	0	2020-01-15 16:26:57	Resultado	0	100	lab2-atv3-7335100-121	lab2-atv3-7335100	zip
69	10770162	1	4	1	2020-01-06 16:50:52	Resultado	0	100	2_4-69	2_4	zip
190	10770180	1	5	1	2020-01-08 16:21:38	Resultado	0	100	lab1_atv2_5_10770180-190	lab1_atv2_5_10770180	zip
191	10770180	1	6	1	2020-01-08 16:21:48	Resultado	0	100	lab1_atv2_6_10770180-191	lab1_atv2_6_10770180	zip
102	10770263	3	3	0	2020-01-15 16:13:57	Resultado	0	100	lab2-atv3-10770263-102	lab2-atv3-10770263	zip
73	10770141	3	3	0	2020-01-15 15:48:10	Resultado	0	100	lab2-atv3-10770141-73	lab2-atv3-10770141	zip
90	10770141	3	1	1	2020-01-15 16:01:40	SCORE	10000	100	fatorial-90	fatorial	c
172	10770141	3	3	0	2020-01-22 15:43:36	Resultado	0	100	lab2-atv3-10770141-172	lab2-atv3-10770141	zip
260	10770217	1	7	1	2020-01-08 16:52:06	Resultado	0	100	2_7-260	2_7	zip
297	andrei	1	4	1	2020-01-20 15:17:16	Resultado	0	100	lab1_atv2_4_10333268-297	lab1_atv2_4_10333268	zip
157	10770109	1	2	1	2020-01-08 15:46:53	Resultado	0	100	lab1_atv2_2_10770109-157	lab1_atv2_2_10770109	zip
29	andrei	1	6	0	2020-01-06 16:37:43	Resultado	0	100	lab1_atv2_6_10333268-29	lab1_atv2_6_10333268	zip
313	10774142	1	6	1	2020-01-20 15:20:40	Resultado	0	100	lab1-atv6-10774142-313	lab1-atv6-10774142	zip
186	10770180	1	1	1	2020-01-08 16:20:49	Resultado	0	100	lab1_atv2_1_10770180-186	lab1_atv2_1_10770180	zip
127	10774142	1	7	0	2020-01-06 17:15:35	Resultado	0	100	lab1_atv2_7_10774142-127	lab1_atv2_7_10774142	zip
168	9373372	3	2	1	2020-01-22 15:38:15	Resultado	0	100	lab2-atv2-9373372-168	lab2-atv2-9373372	zip
166	10333362	1	1	1	2020-01-08 16:14:25	Resultado	0	100	lab1-atv1-10333362-166	lab1-atv1-10333362	zip
11	10336852	1	2	1	2020-01-06 16:04:33	Resultado	0	100	lab1_atv2_2_10336852-11	lab1_atv2_2_10336852	zip
187	10770180	1	2	1	2020-01-08 16:21:04	Resultado	0	100	lab1_atv2_2_10770180-187	lab1_atv2_2_10770180	zip
82	9395032	1	1	0	2020-01-06 16:55:40	Resultado	0	100	lab1_atv2_1_9395032-82	lab1_atv2_1_9395032	zip
144	10394382	1	5	1	2020-01-06 17:26:28	Resultado	0	100	lab1_atv2_5_10394382-144	lab1_atv2_5_10394382	zip
202	10772612	1	4	1	2020-01-08 16:25:06	Resultado	0	100	lav1_atv2_4_10772612-202	lav1_atv2_4_10772612	zip
170	10706110	1	2	1	2020-01-08 16:16:12	Resultado	0	100	2_2-170	2_2	zip
89	10274461	1	1	0	2020-01-06 16:57:18	Resultado	0	100	lab1_atv2_1_10274461-89	lab1_atv2_1_10274461	zip
215	8041400	1	5	1	2020-01-08 16:29:34	Resultado	0	100	lab1_atv2_5_8041400-215	lab1_atv2_5_8041400	zip
92	10274461	1	2	0	2020-01-06 16:57:42	Resultado	0	100	lab1_atv2_2_10274461-92	lab1_atv2_2_10274461	zip
97	10274461	1	6	0	2020-01-06 16:59:45	Resultado	0	100	lab1_atv2_6_10274461-97	lab1_atv2_6_10274461	zip
322	10705613	1	6	1	2020-01-20 15:41:47	Resultado	0	100	2_6-322	2_6	zip
326	9395032	1	1	1	2020-01-20 15:59:17	Resultado	0	100	2_1-326	2_1	zip
178	10770180	1	5	0	2020-01-08 16:16:59	Resultado	0	100	2_5-178	2_5	zip
343	9833173	1	1	1	2020-01-22 15:15:10	Resultado	0	100	lab1_atv2_1_9833173-343	lab1_atv2_1_9833173	zip
180	10770180	1	6	0	2020-01-08 16:17:12	Resultado	0	100	2_6-180	2_6	zip
298	andrei	1	5	1	2020-01-20 15:17:36	Resultado	0	100	lab1_atv2_5_10333268-298	lab1_atv2_5_10333268	zip
49	10770141	2	1	0	2020-01-22 15:11:43	Resultado	0	100	lab1-atv3-10770141-49	lab1-atv3-10770141	zip
15	10770263	2	1	0	2020-01-08 17:09:20	Resultado	0	100	lab1-atv3-10770263-15	lab1-atv3-10770263	zip
3	9395032	2	1	0	2020-01-06 16:13:22	Resultado	0	100	lab1_atv2_1_9395032-3	lab1_atv2_1_9395032	zip
31	10333397	2	1	1	2020-01-15 16:37:37	Resultado	0	100	lab1-atv3-10333397-31	lab1-atv3-10333397	zip
25	10770109	2	1	1	2020-01-15 14:42:33	Resultado	0	100	lab1_atv3_10770109-25	lab1_atv3_10770109	zip
8	9395032	2	1	1	2020-01-06 17:24:20	Resultado	0	100	Misterio-8	Misterio	zip
6	10336852	2	1	0	2020-01-06 17:02:40	Resultado	0	100	lab1-atv3-10336852-6	lab1-atv3-10336852	zip
148	10394382	3	2	1	2020-01-20 15:26:49	Resultado	0	100	lab2-atv2-10394382-148	lab2-atv2-10394382	zip
152	10773096	3	3	1	2020-01-20 15:37:28	Resultado	0	100	lab2-atv3-10773096-152	lab2-atv3-10773096	zip
30	10774782	4	1	1	2020-01-20 15:09:10	Resultado	0	100	lab2-atv4-10774782-30	lab2-atv4-10774782	zip
35	10770093	4	1	1	2020-01-20 15:55:59	Resultado	0	100	lab2-atv4-10770093-35	lab2-atv4-10770093	zip
145	10394382	1	6	1	2020-01-06 17:26:40	Resultado	0	100	lab1_atv2_6_10394382-145	lab1_atv2_6_10394382	zip
335	10274461	1	3	0	2020-01-20 16:09:05	Resultado	0	100	lab1_atv2_3_10274461-335	lab1_atv2_3_10274461	zip
340	10274461	1	3	1	2020-01-20 16:10:13	Resultado	0	100	lab2-atv3-10274461-340	lab2-atv3-10274461	zip
206	10772612	1	5	0	2020-01-08 16:25:25	Resultado	0	100	lav1_atv2_6_10772612-206	lav1_atv2_6_10772612	zip
299	andrei	1	6	1	2020-01-20 15:17:55	Resultado	0	100	lab1_atv2_6_10333268-299	lab1_atv2_6_10333268	zip
84	9395032	1	2	0	2020-01-06 16:56:04	Resultado	0	100	lab1_atv2_2_9395032-84	lab1_atv2_2_9395032	zip
334	10274461	1	2	1	2020-01-20 16:08:52	Resultado	0	100	lab1_atv2_2_10274461-334	lab1_atv2_2_10274461	zip
301	10687472	1	1	1	2020-01-20 15:18:25	Resultado	0	100	2_1-301	2_1	zip
177	10773210	3	3	1	2020-01-22 16:06:53	Resultado	0	100	lab2-atv3-10773210-177	lab2-atv3-10773210	zip
211	8041400	1	1	0	2020-01-08 16:27:35	Resultado	0	100	lab1_atv2_1_8041400-211	lab1_atv2_1_8041400	zip
219	10773210	1	2	1	2020-01-08 16:38:37	Resultado	0	100	lab1_atv2_2_10773210-219	lab1_atv2_2_10773210	zip
169	9373372	3	3	1	2020-01-22 15:38:59	Resultado	0	100	lab2-atv3-9373372-169	lab2-atv3-9373372	zip
220	10773210	1	3	1	2020-01-08 16:41:08	Resultado	0	100	lab1_atv2_3_10773210-220	lab1_atv2_3_10773210	zip
224	10773210	1	6	1	2020-01-08 16:45:51	Resultado	0	100	lab1_atv2_6_10773210-224	lab1_atv2_6_10773210	zip
19	10773353	1	4	1	2020-01-06 16:30:18	Resultado	0	100	lab1_atv2_4_10773353-19	lab1_atv2_4_10773353	zip
35	10773353	1	6	1	2020-01-06 16:39:43	Resultado	0	100	lab1_atv2_6_10773353-35	lab1_atv2_6_10773353	zip
115	10773968	1	1	1	2020-01-06 17:06:36	Resultado	0	100	lab1_atv2_1_10773968-115	lab1_atv2_1_10773968	zip
90	9395032	1	6	0	2020-01-06 16:57:20	Resultado	0	100	lab1_atv2_6_9395032-90	lab1_atv2_6_9395032	zip
28	10774782	1	3	1	2020-01-06 16:37:29	Resultado	0	100	2_3-28	2_3	zip
61	10774782	1	4	1	2020-01-06 16:50:26	Resultado	0	100	2_4-61	2_4	zip
70	10774782	1	5	1	2020-01-06 16:51:00	Resultado	0	100	2_5-70	2_5	zip
272	8572921	1	1	1	2020-01-08 17:03:26	Resultado	0	100	lab1_atv2_1_8572921-272	lab1_atv2_1_8572921	zip
86	9344880	1	4	1	2020-01-06 16:56:31	Resultado	0	100	lab1-atv2_4-9344880-86	lab1-atv2_4-9344880	zip
112	9344880	1	5	1	2020-01-06 17:03:15	Resultado	0	100	lab1-atv2_5-9344880-112	lab1-atv2_5-9344880	zip
62	9395004	1	4	1	2020-01-06 16:50:26	Resultado	0	100	lab1_atv2_4_9395004-62	lab1_atv2_4_9395004	zip
67	9395004	1	5	1	2020-01-06 16:50:48	Resultado	0	100	lab1_atv2_5_9395004-67	lab1_atv2_5_9395004	zip
74	9395004	1	6	1	2020-01-06 16:51:09	Resultado	0	100	lab1_atv2_6_9395004-74	lab1_atv2_6_9395004	zip
48	9373372	4	1	1	2020-01-22 16:18:08	Resultado	0	100	lab1_atv3_9373372-48	lab1_atv3_9373372	zip
47	9784439	4	1	0	2020-01-22 15:59:03	Resultado	0	100	lab2-atv4-9784439-47	lab2-atv4-9784439	zip
98	9395004	1	7	1	2020-01-06 17:00:04	Resultado	0	100	lab1_atv2_7_9395004-98	lab1_atv2_7_9395004	zip
94	10274461	1	3	0	2020-01-06 16:58:46	Resultado	0	100	lab1_atv2_3_10274461-94	lab1_atv2_3_10274461	zip
271	9784439	1	1	1	2020-01-08 17:03:16	Resultado	0	100	lab1_atv2_1_9784439-271	lab1_atv2_1_9784439	zip
51	5051111	4	1	1	2020-01-22 16:57:45	Resultado	0	100	lab2-atv4-5051111-51	lab2-atv4-5051111	zip
50	10773210	4	1	0	2020-01-22 16:50:41	Resultado	0	100	lab-atv4-10773210-50	lab-atv4-10773210	zip
287	9784439	1	3	1	2020-01-08 17:05:41	Resultado	0	100	lab1_atv2_3_9784439-287	lab1_atv2_3_9784439	zip
289	9784439	1	4	1	2020-01-08 17:06:00	Resultado	0	100	lab1_atv2_4_9784439-289	lab1_atv2_4_9784439	zip
53	10773374	1	1	0	2020-01-06 16:49:07	Resultado	0	100	2_4-53	2_4	zip
83	9344880	1	1	0	2020-01-06 16:55:58	Resultado	0	100	lab1-atv2_4-9344880-83	lab1-atv2_4-9344880	zip
30	andrei	1	7	0	2020-01-06 16:38:03	Resultado	0	100	lab1_atv2_7_10333268-30	lab1_atv2_7_10333268	zip
116	10773096	1	2	0	2020-01-06 17:06:53	Resultado	0	100	lab1_atv2_2_10773096-116	lab1_atv2_2_10773096	zip
53	10770217	2	1	0	2020-01-22 16:04:23	Resultado	0	100	clmistery-53	clmistery	zip
55	9833173	2	1	1	2020-01-22 16:08:07	Resultado	0	100	lab1_atv3_9833173-55	lab1_atv3_9833173	zip
277	10333205	1	2	1	2020-01-08 17:04:18	Resultado	0	100	lab1_atv2_2_10333205-277	lab1_atv2_2_10333205	zip
96	9784439	3	1	0	2020-01-15 16:07:46	Compilation Error	0	100	fatorial-96	fatorial	c
132	10336831	1	5	1	2020-01-06 17:17:08	Resultado	0	100	lab1_atv2_5_10336831-132	lab1_atv2_5_10336831	zip
133	10336831	1	6	1	2020-01-06 17:17:21	Resultado	0	100	lab1_atv2_6_10336831-133	lab1_atv2_6_10336831	zip
134	10336831	1	7	1	2020-01-06 17:17:33	Resultado	0	100	lab1_atv2_7_10336831-134	lab1_atv2_7_10336831	zip
99	10774142	1	2	0	2020-01-06 17:00:21	Resultado	0	100	lab1_atv2_2_10774142-99	lab1_atv2_2_10774142	zip
176	5051111	3	3	1	2020-01-22 15:58:23	Resultado	0	100	lab2-atv3-5051111-176	lab2-atv3-5051111	zip
45	9373372	4	1	0	2020-01-22 15:40:15	Resultado	0	100	lab2_atv4_9373372-45	lab2_atv4_9373372	zip
57	10770263	3	1	0	2020-01-15 15:31:25	SCORE	6666	100	fatorial-57	fatorial	c
83	8041400	3	2	0	2020-01-15 15:53:25	Resultado	0	100	lab2-atv2-8041400-83	lab2-atv2-8041400	zip
77	9833173	3	1	0	2020-01-15 15:50:34	Compilation Error	0	100	fatorial-77	fatorial	c
113	8041400	3	1	0	2020-01-15 16:19:55	SCORE	0	100	lab2-atv1-8041400-113	lab2-atv1-8041400	c
42	10773968	3	2	0	2020-01-13 16:50:31	Resultado	0	100	lab2_atv2-10773968-42	lab2_atv2-10773968	zip
31	10274461	3	1	0	2020-01-13 16:31:54	Resultado	0	100	lab2-atv1_1-10274461-31	lab2-atv1_1-10274461	zip
112	8041400	3	1	0	2020-01-15 16:19:30	SCORE	0	100	lab2-atv3-8041400-112	lab2-atv3-8041400	c
6	9395032	3	1	1	2020-01-13 15:54:18	Resultado	0	100	1-1-6	1-1	zip
15	10773374	3	1	0	2020-01-13 16:05:12	Resultado	0	100	lab2-atv2-10773374-15	lab2-atv2-10773374	zip
10	9345234	3	1	1	2020-01-13 16:03:00	Resultado	0	100	Fatorial-10	Fatorial	zip
27	10394382	3	1	1	2020-01-13 16:21:16	Resultado	0	100	fatorial-27	fatorial	zip
34	10770238	3	3	0	2020-01-13 16:37:10	Resultado	0	100	lab2_atv2_10770238-34	lab2_atv2_10770238	zip
95	9784439	3	1	0	2020-01-15 16:06:24	Compilation Error	0	100	Fatorial-95	Fatorial	c
92	9784439	3	1	0	2020-01-15 16:04:39	Compilation Error	0	100	Fatorial-92	Fatorial	c
100	10774142	1	3	0	2020-01-06 17:00:32	Resultado	0	100	lab1_atv2_3_10774142-100	lab1_atv2_3_10774142	zip
42	10770093	1	1	1	2020-01-06 16:47:49	Resultado	0	100	2_1-42	2_1	zip
13	9395004	3	3	1	2020-01-13 16:03:50	Resultado	0	100	lab2-atv3-9395004-13	lab2-atv3-9395004	zip
32	9395032	3	2	1	2020-01-13 16:32:08	Resultado	0	100	1-2-32	1-2	zip
37	9395032	3	3	1	2020-01-13 16:41:44	Resultado	0	100	1-3-37	1-3	zip
135	9784439	3	2	1	2020-01-15 16:44:50	Resultado	0	100	lab2-atv2-9784439-135	lab2-atv2-9784439	zip
107	9833173	3	2	1	2020-01-15 16:15:40	Resultado	0	100	lab2-atv2-9833173-107	lab2-atv2-9833173	zip
123	9833173	3	3	1	2020-01-15 16:28:21	Resultado	0	100	ex2-atv3-9833173-123	ex2-atv3-9833173	zip
147	10773374	3	1	1	2020-01-20 15:13:12	SCORE	10000	100	fatorial-147	fatorial	c
41	9344880	3	1	0	2020-01-13 16:49:50	Resultado	0	100	lab2-atv4-9344880-41	lab2-atv4-9344880	zip
50	10774142	3	2	0	2020-01-13 17:04:31	Resultado	0	100	lab2_atv2_10774142-50	lab2_atv2_10774142	zip
82	9833173	3	1	1	2020-01-15 15:52:35	SCORE	10000	100	fatorial-82	fatorial	c
103	10333362	3	1	1	2020-01-15 16:14:31	SCORE	10000	100	fatorial-103	fatorial	c
52	10274461	3	2	1	2020-01-13 17:10:47	Resultado	0	100	lab2-atv2-10274461-52	lab2-atv2-10274461	zip
98	10333362	3	2	1	2020-01-15 16:08:57	Resultado	0	100	lab2-atv2-10333362-98	lab2-atv2-10333362	zip
9	10336852	3	3	1	2020-01-13 15:58:41	Resultado	0	100	lab2-atv3-10336852-9	lab2-atv3-10336852	zip
68	10706110	3	1	1	2020-01-15 15:47:20	SCORE	10000	100	fatorial-68	fatorial	c
75	10706110	3	2	1	2020-01-15 15:49:00	Resultado	0	100	lab2-atv2-10706110-75	lab2-atv2-10706110	zip
69	10770141	3	2	1	2020-01-15 15:47:43	Resultado	0	100	lab2-atv2-10770141-69	lab2-atv2-10770141	zip
86	10770180	3	3	1	2020-01-15 15:58:40	Resultado	0	100	lab2-atv3-10770180-86	lab2-atv3-10770180	zip
26	10773968	3	1	1	2020-01-13 16:20:38	Resultado	0	100	fatorial-26	fatorial	zip
48	9345234	3	2	1	2020-01-13 17:02:14	Resultado	0	100	lab2-atv2-9345234-48	lab2-atv2-9345234	zip
33	10705613	3	1	1	2020-01-13 16:32:30	Resultado	0	100	fatorial-33	fatorial	zip
143	10774782	3	1	1	2020-01-20 15:04:54	SCORE	10000	100	fatorial-143	fatorial	c
20	10774142	3	1	0	2020-01-13 16:10:52	Resultado	0	100	lab2_atv1_10774142-20	lab2_atv1_10774142	zip
151	10773096	3	2	1	2020-01-20 15:37:07	Resultado	0	100	lab2-atv2-10773096-151	lab2-atv2-10773096	zip
154	andrei	3	1	1	2020-01-20 15:46:01	SCORE	10000	100	fatorial-154	fatorial	c
7	10770162	3	1	0	2020-01-13 15:58:08	Resultado	0	100	fatorial-7	fatorial	zip
87	9395032	1	5	0	2020-01-06 16:56:44	Resultado	0	100	lab1_atv2_5_9395032-87	lab1_atv2_5_9395032	zip
93	9395032	1	7	0	2020-01-06 16:57:47	Resultado	0	100	lab1_atv2_7_9395032-93	lab1_atv2_7_9395032	zip
136	10274461	1	7	0	2020-01-06 17:19:47	Resultado	0	100	lab1_atv2_7_10274461-136	lab1_atv2_7_10274461	zip
75	10774782	1	6	1	2020-01-06 16:51:11	Resultado	0	100	2_6-75	2_6	zip
78	10774782	1	7	1	2020-01-06 16:51:22	Resultado	0	100	2_7-78	2_7	zip
222	5051111	1	1	1	2020-01-08 16:45:25	Resultado	0	100	lab1_atv2_1_5051111-222	lab1_atv2_1_5051111	zip
36	9344880	1	1	1	2020-01-06 16:42:31	Resultado	0	100	lab1-atv2_1-9344880-36	lab1-atv2_1-9344880	zip
117	9344880	1	6	1	2020-01-06 17:07:04	Resultado	0	100	lab1-atv2_6-9344880-117	lab1-atv2_6-9344880	zip
46	9395004	1	1	1	2020-01-06 16:48:19	Resultado	0	100	lab1_atv2_1_9395004-46	lab1_atv2_1_9395004	zip
58	9395004	1	3	1	2020-01-06 16:49:59	Resultado	0	100	lab1_atv2_3_9395004-58	lab1_atv2_3_9395004	zip
290	9784439	1	6	1	2020-01-08 17:06:12	Resultado	0	100	lab1_atv2_6_9784439-290	lab1_atv2_6_9784439	zip
265	9784439	1	3	0	2020-01-08 16:56:09	Resultado	0	100	2_3-265	2_3	zip
267	9784439	1	5	0	2020-01-08 16:56:37	Resultado	0	100	2_5-267	2_5	zip
232	7335100	1	1	0	2020-01-08 16:47:03	Resultado	0	100	2_1-232	2_1	zip
54	10770217	2	1	1	2020-01-22 16:06:53	Resultado	0	100	clmystery-54	clmystery	zip
171	10773210	3	2	1	2020-01-22 15:43:32	Resultado	0	100	makefile-test-171	makefile-test	zip
49	9784439	4	1	1	2020-01-22 16:46:20	Resultado	0	100	lab2-atv4-9784439-49	lab2-atv4-9784439	zip
208	10772612	1	6	1	2020-01-08 16:25:50	Resultado	0	100	lav1_atv2_6_10772612-208	lav1_atv2_6_10772612	zip
148	10773096	1	2	1	2020-01-06 17:35:57	Resultado	0	100	lab1_atv2_2_10773096-148	lab1_atv2_2_10773096	zip
149	10773096	1	3	1	2020-01-06 17:36:11	Resultado	0	100	lab1_atv2_3_10773096-149	lab1_atv2_3_10773096	zip
137	10773096	1	7	1	2020-01-06 17:20:34	Resultado	0	100	lab1_atv2_7_10773096-137	lab1_atv2_7_10773096	zip
57	5456321	2	1	0	2020-01-22 17:06:50	Resultado	0	97	lab1-atv3-5456321-57	lab1-atv3-5456321	zip
\.


--
-- Data for Name: shj_users; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_users (id, username, password, display_name, email, role, passchange_key, passchange_time, first_login_time, last_login_time, selected_assignment, dashboard_widget_positions) FROM stdin;
26	10333251	$2a$08$XD3bACAzwCRlrgrg22IRvuwBZoV/dAtUwYmgmKIlQpt2dzqoLyBB6		joaovitorvargassoares@usp.br	student		\N	2020-01-15 15:24:10	2020-01-22 15:16:34	1	
11	8803195	$2a$08$ghp9aYVd9x8WjdedmXR2GOltOoHf5g.AO57xljLhZC4uZ8MluQ9G2		diogo.vaccaro@usp.br	student		\N	\N	\N	0	
18	9762615	$2a$08$4PMYsWMopRg57NH2j52x0O8v3/0HMwzf4rOLlYORuRa7ClFYmbcMW		gabriel.villela.queiroz@usp.br	student		\N	\N	\N	0	
29	8587538	$2a$08$lECad143PhDOQnZgKcAHmOfEdk75mdOYc1CIjk5ZMY3pVsp8uj.NW		lucas.eugenio@usp.br	student		\N	\N	\N	0	
35	9833131	$2a$08$E85sReN/G0cqepvbTKtVq.CPHSQyXphbhAfaflJtzJwzJ5qJDJ12u		lucas.tamai@usp.br	student		\N	\N	\N	0	
45	8988640	$2a$08$aGMxBz8IY4xbqqj1bi5fQujlwhQELSYw.Sv.K.Xoi8hFy/xWZjmDK		roberto.azevedo@usp.br	student		\N	\N	\N	0	
10	10770263	$2a$08$fYBDb2Mv51DUKae7y4xLE.lzehFeEFhLNErjzho7FxXqqeQgSNdDy	Bruno M. Sanches	brunosanches@usp.br	student		\N	2020-01-08 14:57:08	2020-01-22 14:56:20	3	
43	10273988	$2a$08$5LIyX.fAowDNBnDrrhRTP.SX0UShRWpz5GfgwrGcvwZ.pKWMYqBcy		rrvsrafael@usp.br	student		\N	2020-01-13 15:34:24	2020-01-13 16:46:27	2	
14	10770217	$2a$08$WYAM/F7IzAFumAmiPLZ0gOW5asVQ4zaZA7D0.j2SONX3NBVmLNinW		fe.jc@usp.br	student		\N	2020-01-08 16:44:04	2020-01-22 14:53:56	2	
2	ricardo	$2a$08$s38xDA1wwYbhd7EhpnBxPOa9PrKooD5qyTMT4uV1Y.C2FvF2kWv4S		rlarocha@usp.br	admin		\N	2020-01-06 16:41:02	2020-01-06 16:41:02	0	
5	10773096	$2a$08$INz6ZDNH/ZOhRhXPuVPbCe5j3ZUjAs1JRXIgYDTNZx88ty9swiLZi	Arthur Pires da Fonseca	arthurpfonseca@usp.br	student		\N	2020-01-06 15:23:39	2020-01-20 15:29:51	5	
39	10394382	$2a$08$/QpKJQnEcUknn.jJsfwez.9HgrmFCtsSa59HjL/Pvuef66rW5aY/C		marcossa@usp.br	student	1bJyBIcoG3WtZX42dCKYnx7zAFj9MViOlSrPvT8ERQ0k5DfL6g	2020-01-06 15:12:46	2020-01-06 15:13:31	2020-01-20 15:16:33	3	
51	10770093	$2a$08$u6JXpqc3ko9cnrdcI7aAWuzp8PhjDUm5R8KV3IWjgQgfVkaKmpYj2		wesleyalmeida@usp.br	student		\N	2020-01-06 15:27:40	2020-01-20 15:23:59	4	
32	10773353	$2a$08$hNWPee066ieRUB1ZUDLWueNE0t.KpDc4y/POBc5tgYe3MZp3op4ki		lucaslssantos99@usp.br	student		\N	2020-01-06 15:26:32	2020-01-20 15:02:39	5	
24	10274461	$2a$08$cK96YhD4LU.RRuFRM8H./.c6R2LtTSSvdANndsxPD9WjUsLP4tMcu	DANIEL JIE ZHU	daniel.jiezhu@usp.br	student		\N	2020-01-06 15:19:26	2020-01-20 16:07:49	1	
16	10774782	$2a$08$EW54ylVXaotU5zdH2bQtX.k.KZwDMJ5ldej8eEjwOe15mBF3t2Uci		gabrielprodrigues@usp.br	student		\N	2020-01-06 16:09:19	2020-01-20 14:59:20	1	
21	9395004	$2a$08$efvBpaCr/924599ue5QxuehKHgsdkM0.Q3PXK1XdWMYQP/vPUlhAa		hugo.cruz@usp.br	student		\N	2020-01-06 15:22:34	2020-01-20 15:08:39	3	
9	10336852	$2a$08$sGPYVXHjx0zwLfhi7izdB.byP/Jxe0wnM/MMSGVBeYBcjpCa35PsC	Bruno	bruno.movio@usp.br	student		\N	2020-01-06 15:12:45	2020-01-20 14:51:29	4	
20	10774142	$2a$08$0lWwmlYpwu8T0jK5smgEK.yfelv6j2PPL2p5Y0w6uDjpHJpBaVuC.		henriquegiabardo@usp.br	student		2020-01-06 16:51:46	2020-01-06 15:23:11	2020-01-20 15:08:27	4	
34	9345234	$2a$08$h7Aqfw.XYGHhoD4e50DviO2sIyqGwEfqr5LSjwKk4bKTFJeT8Z3wi		lucas.seiji.saito@usp.br	student		\N	2020-01-13 15:18:46	2020-01-13 16:57:53	3	
40	10333397	$2a$08$/Ew7yXR26XvOGl9tP/tNJefIXPz4qiPkOo3IHMOl5L4uFnn4Xrfe2		m.corradini@usp.br	student		\N	2020-01-15 15:17:52	2020-01-22 15:56:06	5	
44	9395032	$2a$08$D.tUfQ7znKcViulJtlxRGOyucIbkqNbx9k8rQhYYHeTLPdwMSX836	Renan Souza	renan.rodrigues.souza@usp.br	student		\N	2020-01-06 15:13:59	2020-01-20 15:34:58	4	
27	7335100	$2a$08$zaBo0L.OXYx9eO8JWn1Tdu.PcWVxv0X7oSN/wrWHUHpopvehgNYxm		jmcosta@usp.br	student		\N	2020-01-08 15:07:25	2020-01-22 14:58:21	4	
31	10336831	$2a$08$F34qJrRZ6tTx4TdtcpmZBud4wUWLJ/Ibv0xtbPdtpErlyzVW4Fs9.	Lucas Leite	lucasleite008@usp.br	student	NCBdnbPoupmft2AqZjxkMyHzawr96YKg0Ghs7TDWE8UleRFv3L	2020-01-06 15:11:49	2020-01-06 15:12:51	2020-01-20 15:20:30	3	
3	jailson	$2a$08$Gnh3Q.mpTThIOQ8e/Cbgu.Shknnp9X7h/sLhcGRE3jZECLCgupHrm		jailsonleocadio@usp.br	admin		\N	2020-01-06 09:52:03	2020-01-06 16:41:10	1	
12	10333205	$2a$08$DScMN2e77rmAJj.P/hL3Le8Ppd1qyWNU1CkmRCmSwOLkUiFt8xyuu		eduardofernandes@usp.br	student		\N	2020-01-08 15:09:01	2020-01-15 16:30:22	4	
7	9784439	$2a$08$mrrmrlmdpdjqeS49AGHiWu7VC7L5kFQFhXCr0PrFdT4P/DzEUGGru	Breno Rocha	brenoloscher@usp.br	student		\N	2020-01-08 15:05:11	2020-01-22 14:40:22	4	
49	5051111	$2a$08$Z5ZoLQ2a.TEGzASNZEfO.ekdmMoQIUxmJWCH3GVFXLd59YfQnYLDy	Tomás Ramos	tfbramos@usp.br	student		\N	2020-01-08 15:21:55	2020-01-22 14:57:18	4	
48	10706110	$2a$08$JC1vn1bFqyqavJEbtwmVf.tDz9qHdhCibBX4R0KRVjqZ2RacXKyx2		thalesasr@usp.br	student		\N	2020-01-08 15:00:39	2020-01-15 15:51:45	3	
47	9833173	$2a$08$7hV61isLrrpcWb50Rase8u8oGAY53yFNGPKexftSSIqeau5okGtza		tamy.yatsu@usp.br	student		\N	2020-01-08 16:44:16	2020-01-22 14:57:17	2	
13	5456321	$2a$08$eIATZUBMNrcBYTLePI4Az.vuMXD0k7ZvAW2x8jqzqywcuJQN93SRm		fabiano.shimura@usp.br	student		\N	2020-01-22 15:41:05	2020-01-22 15:41:05	2	
37	10773210	$2a$08$l55PqhFJ674pSzpLFITKNeGZjnE.VEjlOtrj4.Q5KzESrkwiIjzCe	luiz higuti	luiz_higuti@usp.br	student		\N	2020-01-08 15:07:24	2020-01-22 14:40:59	4	
38	10772612	$2a$08$ASCGV7LD7iz/P0d.Of.twOz.8gm0c74uKQ9Xsd0FTTHNP/c58iRpi	Marcin	marciosuguiyama@usp.br	student		\N	2020-01-08 15:02:44	2020-01-15 14:48:21	3	
41	10773374	$2a$08$u9CF0Rou7nNO2aNB3N9ZdeuQksV09TxFJpQlsWOsO8BV.B6fiXzHC		paulo.rubens@usp.br	student		\N	2020-01-06 15:55:47	2020-01-20 15:01:20	3	
4	10770162	$2a$08$ZLbCizbECc4BuJ3C/H.kZOPJgqIEVbgr/Q5l1kpY0DjCIrRWF2I/y		pietrosantana@usp.br	student		\N	2020-01-06 15:28:59	2020-01-20 15:34:19	1	
50	8041400	$2a$08$yKj05DJ99F6s9qkiIjBEaegQAgykilPV9xD0mv8GEJ8yAo6LG1fMm		walter.ventura@usp.br	student		\N	2020-01-08 16:26:06	2020-01-15 15:52:04	4	
23	10333362	$2a$08$CQOwZm7NGWoy5BkLQs1rFujYrqN48XInmsLFa672v31Ham2tyD7zK		jeanleeb@usp.br	student		\N	2020-01-08 15:08:20	2020-01-22 14:47:27	3	
52	miguel	$2a$08$eO87QIKdwTqVcviwkmeZ3OsgtH.mK8PRkbt6Tcrxzdbu4kfgW6goO		miguel.sarraf@usp.br	admin		\N	2020-01-06 14:34:43	2020-01-22 20:26:05	4	
46	10770200	$2a$08$Lvedw2uNj82q4.7o5Z0KJu68HfMiUiw26a.bfoU21KSLfkhPTSncu		sergioagf10@usp.br	student		\N	2020-01-08 14:57:53	2020-01-22 14:40:26	4	
30	10770180	$2a$08$qbP4RJV/i7ZjLWCLnhvY5.5AMR4YbUBvLq.2d469lTuUrA5rI13L.		lucasdemenezes@usp.br	student		\N	2020-01-08 15:45:17	2020-01-15 15:49:35	4	
6	10705613	$2a$08$fjQZYjjJZXVznZdZCOB.SedIqCNN9zu6TEKe.h2s9eyuyXpkEyFIW		arturvribeiro@usp.br	student		\N	2020-01-13 15:16:47	2020-01-20 15:19:08	2	
17	10770141	$2a$08$YbGVk6Qu0rfErW6w3y9y1enJeisBYjINpcU9FgstFQBmfE3G4rx4y		gabriel.sanefuji@usp.br	student		\N	2020-01-08 15:21:42	2020-01-22 15:11:11	3	
42	9373372	$2a$08$6Z8Wspkj8oS9mDge0cX1Au2BVt/DOsjuMU78qmh8khXmtIWhIv1Nm		rafael.augusto.neves@usp.br	student		\N	2020-01-08 15:34:49	2020-01-22 15:20:36	3	
1	michelet	$2a$08$TOu.MgphSKsf1h/IokoBJuiP9Nd95VNrSbDL1uw1eXk8lIeGrEAw6		michelet@usp.br	admin		\N	2019-12-28 05:06:09	2020-01-23 08:47:51	5	
33	9344880	$2a$08$zR3ye7dOXnFHvuhcDWVIje3b0juyScBHtjsu3qa3GuGbFSKRD46n.		lucas.lopes.paula@usp.br	student		2020-01-13 15:18:05	2020-01-06 15:20:45	2020-01-20 15:34:26	3	
36	10773116	$2a$08$c25YxiATDjGAnH4yQntKb.LYnpuRHUGF4mJi3ECfEsSzUuzn5B1oO		luiz.kasputis@usp.br	student		\N	2020-01-06 15:21:22	2020-01-20 15:58:22	2	
19	10770238	$2a$08$QHqiU1suf26.kFrWNxqWCuhzpSbSqDglKE6jJEkHEuawp84FePOim		helcioxpl@usp.br	student		\N	2020-01-06 15:46:16	2020-01-20 16:21:59	1	[{"r":1,"c":1,"x":1,"y":1},{"r":1,"c":2,"x":1,"y":1},{"r":2,"c":1,"x":1,"y":1}]
53	andrei	$2a$08$AemWEaBkwVdIEEMocPTOle8Ul1ZViEKbfglFhQ534.XRjy84uVzQG		andrei.sgi97@usp.br	student		\N	2020-01-06 15:37:44	2020-01-20 15:15:23	4	
15	10773968	$2a$08$.Y/KmJUmkROTbfgtY1QWWu0/xalP4SD9HQOSvQLrxn20N5e75QhJK	Gabriel Morghett Gaboardi	gabriel.morghett@usp.br	student		\N	2020-01-06 15:23:22	2020-01-20 15:06:28	4	
22	8572921	$2a$08$NaS0pu0z3yvV4Pr6.taO3OxWdfcFIZ87wqQyqIVFNCK4Oj11rT8/q	iago	iago.monteiro@usp.br	student		2020-01-08 15:02:58	2020-01-08 15:04:19	2020-01-22 14:41:26	4	
54	10770109	$2a$08$tVUyeWQzAuqSWra9aubbl.daP3z8GqyzFUKuhAr8.a93h.yyhwZ1i		joao.henriquek@usp.br	student		\N	2020-01-08 15:24:21	2020-01-22 14:56:26	4	
8	10687472	$2a$08$ttB6Y6CR4G/BRkhKxmi9UeWi8/6ADX7uHXmPqq0L0j6b86CPasY6O	Bruno Borges Paschoalinoto	bruno_bp@usp.br	student		\N	2020-01-06 15:37:53	2020-01-20 15:17:40	1	
28	10770120	$2a$08$ygKABCjRp9ZEnC/hrdWQ1ue7GTvUIyONsnAXR/Gj3Qif1sLfZJHtK		leocassianoure@usp.br	student		\N	2020-01-08 15:20:05	2020-01-22 15:13:48	2	
\.


--
-- Data for Name: shj_users_classes; Type: TABLE DATA; Schema: public; Owner: sharifjudge
--

COPY public.shj_users_classes (user_id, class_id, responsible) FROM stdin;
\.


--
-- Name: shj_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sharifjudge
--

SELECT pg_catalog.setval('public.shj_users_id_seq', 54, true);


--
-- Name: pk_shj_assignments; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_assignments
    ADD CONSTRAINT pk_shj_assignments PRIMARY KEY (id);


--
-- Name: pk_shj_classes; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_classes
    ADD CONSTRAINT pk_shj_classes PRIMARY KEY (id);


--
-- Name: pk_shj_notifications; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_notifications
    ADD CONSTRAINT pk_shj_notifications PRIMARY KEY (id);


--
-- Name: pk_shj_queue; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_queue
    ADD CONSTRAINT pk_shj_queue PRIMARY KEY (id);


--
-- Name: pk_shj_sessions; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_sessions
    ADD CONSTRAINT pk_shj_sessions PRIMARY KEY (session_id);


--
-- Name: pk_shj_users; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_users
    ADD CONSTRAINT pk_shj_users PRIMARY KEY (id);


--
-- Name: pk_shj_users_classes; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_users_classes
    ADD CONSTRAINT pk_shj_users_classes PRIMARY KEY (user_id, class_id);


--
-- Name: shj_suap_unique; Type: CONSTRAINT; Schema: public; Owner: sharifjudge; Tablespace: 
--

ALTER TABLE ONLY public.shj_queue
    ADD CONSTRAINT shj_suap_unique UNIQUE (submit_id, username, assignment, problem);


--
-- Name: shj_assignments_classes_assignment_id; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_assignments_classes_assignment_id ON public.shj_assignments_classes USING btree (assignment_id);


--
-- Name: shj_assignments_classes_class_id; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_assignments_classes_class_id ON public.shj_assignments_classes USING btree (class_id);


--
-- Name: shj_problems_assignment_id; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_problems_assignment_id ON public.shj_problems USING btree (assignment, id);


--
-- Name: shj_scoreboard_assignment; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_scoreboard_assignment ON public.shj_scoreboard USING btree (assignment);


--
-- Name: shj_sessions_last_activity; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_sessions_last_activity ON public.shj_sessions USING btree (last_activity);


--
-- Name: shj_settings_shj_key; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_settings_shj_key ON public.shj_settings USING btree (shj_key);


--
-- Name: shj_submissions_assignment_submit_id; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_submissions_assignment_submit_id ON public.shj_submissions USING btree (assignment, submit_id);


--
-- Name: shj_users_username; Type: INDEX; Schema: public; Owner: sharifjudge; Tablespace: 
--

CREATE INDEX shj_users_username ON public.shj_users USING btree (username);


--
-- Name: shj_assignment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_assignments_classes
    ADD CONSTRAINT shj_assignment_fkey FOREIGN KEY (assignment_id) REFERENCES public.shj_assignments(id) ON DELETE CASCADE;


--
-- Name: shj_class_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_assignments_classes
    ADD CONSTRAINT shj_class_fkey FOREIGN KEY (class_id) REFERENCES public.shj_classes(id) ON DELETE CASCADE;


--
-- Name: shj_classes_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_users_classes
    ADD CONSTRAINT shj_classes_fkey FOREIGN KEY (class_id) REFERENCES public.shj_classes(id) ON DELETE CASCADE;


--
-- Name: shj_user_classes_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sharifjudge
--

ALTER TABLE ONLY public.shj_users_classes
    ADD CONSTRAINT shj_user_classes_fkey FOREIGN KEY (user_id) REFERENCES public.shj_users(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

