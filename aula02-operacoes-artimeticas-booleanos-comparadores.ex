# ARITIMÉTICA BÁSICA

# iex> console interativo

# Elixir suporta os operadores básicos + (soma), - (subtração), * (multiplição), e / (divisão) como era de se esperar.
#  É importante ressaltar que / (divisão) sempre retornará um número ponto flutuante.

iex> 2 + 2
  # 4
iex> 2 - 1
  # 1
iex> 2 * 5
  # 10
iex> 10 / 5
  # 2.0

# para retornar uma divisão inteira ou o resto da divisão,
#  pode invocar as funções div (resultado da divisão inteira) e rem (resto da divisão);

# dividendo |_divisor_
#   resto    quociente

#  10 |_5_
# -10   2
#  --
#  0

iex> div(10, 5)
  # 2
iex> rem(10, 5)
  # 0

iex> div 10, 2
  # 5
iex> rem 10, 3
  # 1

# Observe que Elixir permite que você elimine os parênteses ao invocar funções nomeadas.
#  Este recurso oferece uma sintaxe mais limpa para escrever declarações e construções de fluxo de controle.


# Elixir provê os operadores booleanos || (or), && (and), e ! (not). Estes suportam qualquer tipo:

iex> -20 || true
  # -20
iex> false || 42
  # 42
iex> 42 && true
  # true
iex> true && 42
  # 42
iex> !42
  # false
iex> !false
  # true

# há três operadores adicionais cujo o primeiro argumento obrigatorio um booleano (true e false):

iex> true and 42
  # 42
iex> false or true
  # true
iex> true or false
  # true
iex> not false
  # true
iex> 42 and true
#  ** (BadBooleanError) expected a boolean on left-side of "and", got: 42
iex> not 42
#  ** (ArgumentError) argument error :erlang.not(42)

# Elixir vem com todos os operadores de comparação que estamos acostumados a usar:
#  == (igual), !=(diferente),
#  === (identico), !== (nao identico),
#  <= (menor igual), >= (maior igual),
#  < (menor) e > (maior).

iex> 1 > 2
#  false
iex> 1 != 2
#  true
iex> 2 == 2
#  true
iex> 2 == 2.0
#  false
iex> 2 <= 3
#  true
iex> 3 <= 3
#  true

# Para comparação uma boa de inteiros e pontos flutuantes usa-se ===:
iex> 2 == 2.0
#  true
iex> 2 === 2.0
#  false
iex> 2.0 === 2.0
#  true

# Uma característica importante do Elixir é que qualquer tipo pode ser comparado;
#  isto é particularmente útil em ordenação. Não precisamos memorizar a ordem de classificação,
#  mas é importante estar ciente de que: < ( maior )

# number < atom < reference < function < port < pid < tuple < map < list < bitstring
#    atom   > number
iex> :hello > 999
#  true
#    tuple            > list
iex> {:hello, :world} > [1, 2, 3]
#  false
#    function               > atom
iex> fn (a, b) -> a + b end > :a
#  true
