# Time
# O Elixir tem alguns módulos que trabalham com tempo.
# Ainda que precise ser notado que essa funcionalidade é limitada para trabalhar com fuso horário UTC.
# funções =  https://hexdocs.pm/elixir/Time.html#summary

# pegando o tempo atual
iex> Time.utc_now
# ~T[18:24:59.858000]

# pode se usar um sigil para criar uma struct Time
iex> t = ~T[18:24:59.858000]
~T[18:24:59.858000]
iex> t.hour
# 18
iex> t.minute
# 24
iex> t.second
# 59
iex> t.microsecond
# {858000, 6}
iex> t.day
# ** (KeyError) key :day not found in: ~T[18:24:59.858000]

# a struct Time contém apenas tempo [hh:mm:ss:ms] de um dia , dados de dia/mês/ano não estão presentes.

# Date
# a struct Date tem as informações sobre a data atual sem nenhuma informação sobre o tempo atual.
# funções = https://hexdocs.pm/elixir/Date.html#summary

iex> Date.utc_today
# ~D[2021-02-15]

iex> d = Date.utc_today
# ~D[2021-02-15]
iex> d.year
# 2021
iex> d.month
# 2
iex> d.day
# 15
iex> d.hour
# ** (KeyError) key :hour not found in: ~D[2021-02-15]

# NaiveDateTime
# a struct NaiveDateTime contém tanto a data e o tempo. A desvantagem é a falta de suporte para fuso horário
# funções = https://hexdocs.pm/elixir/NaiveDateTime.html#summary

iex> NaiveDateTime.utc_now
# ~N[2021-02-15 18:51:33.849000]

iex> n = NaiveDateTime.utc_now
# ~N[2021-02-15 18:55:17.947000]
iex> n.day
# 15
iex> n.hour
# 18

# DateTime
# Não possui as limitações mencionadas no NaiveDateTime: possui data e hora e suporta fusos horários
# funções = https://hexdocs.pm/elixir/DateTime.html#summary

# Mas esteja ciente dos fusos horários.
# Muitas funções neste módulo requerem um fuso horário do banco de dados.
# Por padrão, é utilizado o fuso horário do banco de dados que é retornado pela função
# Calendar.get_time_zone_database/0, cujo padrão é Calendar.UTCOnlyTimeZoneDatabase,
# que lida apenas com as datas “Etc/UTC” e retorna {:error, :utc_only_time_zone_database}
# para qualquer outro fuso horário.

iex> DateTime.utc_now()
# ~U[2021-02-15 19:05:53.172000Z]
iex> DateTime.now("Etc/UTC")
# {:ok, ~U[2021-02-15 19:05:55.024000Z]}

iex> dt = DateTime.utc_now()
# ~U[2021-02-15 19:05:53.172000Z]
iex(24)> dt.day
# 15
iex> dt.hour
# 19
iex(25)> dt.calendar
# Calendar.ISO
iex(26)> dt.time_zone
# "Etc/UTC"
iex(27)> dt.utc_offset
# 0
iex(28)> dt.std_offset
# 0

iex> {:ok, datetime} = DateTime.now("Etc/UTC")
# {:ok, ~U[2021-02-15 19:11:13.095000Z]}
iex> datetime.time_zone
# "Etc/UTC"
iex> datetime.hour
# 19


# no projeto mix adicionar tzdata (https://github.com/lau/tzdata) como dependência.
# por padrão, o Elixir não possui dados de fuso horário.
# você deve configurar globalmente o Elixir para usar o Tzdata com o fuso horário do banco de dados:
# https://hexdocs.pm/elixir/Config.html#content

# em config/config.exs coloca se:

# import Config
# config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# iex -S mix no projeto para inicia-lo

# vamos criar um horário no fuso horário de Paris
iex> paris_datetime = DateTime.from_naive!(~N[2021-02-02 12:00:00], "Europe/Paris")
# #DateTime<2021-02-02 12:00:00+01:00 CET Europe/Paris>

# e convertê-lo para o horário de Nova York
iex> {:ok, newyork_datetime} = DateTime.shift_zone(paris_datetime, "America/New_York")
# {:ok, #DateTime<2021-02-02 06:00:00-05:00 EST America/New_York>}
iex> newyork_datetime
# #DateTime<2021-02-02 06:00:00-05:00 EST America/New_York>

o Timex(https://github.com/bitwalker/timex) e Calendar(https://github.com/lau/calendar)
que são bibliotecas poderosas para trabalhar com tempo no Elixir
