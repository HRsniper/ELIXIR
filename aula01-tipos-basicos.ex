# TIPOS BASICOS

# iex> console interativo

# INTEIROS
  # O suporte para números binários, octais e hexadecimais também estão inclusos
iex> 200
iex> 0b0110

# PONTOS FLUTUANTES
# Em Elixir, os números de ponto flutuante requerem um decimal depois de pelo menos um dígito;
  # estes possuem uma precisão de 64 bits e suportam e para números exponenciais(notação científica):
iex> 3.14
iex> 1.0e-10

# BOOLEANOS
# Elixir suporta true e false como booleanos; todo valor é verdadeiro com exceção de false e nil:
iex> true
iex> false

# ATOMOS
# Um átomo é uma constante cujo o nome é seu valor. estes são equivalentes aos símbolos,Eles costumam ser úteis para enumerar valores distintos:
iex> :watermelon

# Freqüentemente, eles são usados ​​para expressar o estado de uma operação, usando valores como :oke :error.
# Booleanos true e false também são os átomos :true e :false, respectivamente.
iex> true == :true

# STRINGS
# As strings em Elixir são codificadas em UTF-8 e são representadas com aspas duplas:
iex> "Hello"

# As strings suportam quebras de linha e caracteres de escape:
iex> "foo
...> bar"
saida> "foo\nbar"

# Elixir também suporta interpolação de string:
iex> string = :world
iex> "hellö #{string}"
saida> "hellö world"

# Você pode imprimir uma string usando a IO.puts/1 função do módulo IO:

iex> IO.puts "hello\nworld"
saida> hello
       world
       :ok
