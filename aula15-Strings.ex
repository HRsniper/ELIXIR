Strings em Elixir são nada mais que uma sequência de bytes. <<97>> == "a" <<122>> == "z"
iex> string = <<104,101,108,108,111>>
# "hello"
iex> string <> <<0>>
# <<104, 101, 108, 108, 111, 0>>

# Ao concatenar a string com o byte 0, o IEx mostra a string como um binário já que este não é mais uma string
# válida. Este truque nos ajuda a identificar a sequência de bytes que compõem qualquer string.

# Internamente, as strings em Elixir são representadas como uma sequência de bytes ao invés de um array
# de caracteres. Elixir também tem um tipo char list (lista de caracteres).
# Strings em Elixir são delimitadas por aspas duplas, enquanto listas de caracteres são delimitadas por
# aspas simples.
# Qual a diferença? Cada valor em uma lista de caracteres corresponde ao número Unicode do caracter,
# enquanto em um binário os valores são codificados em UTF-8.

iex> 'hełło'
# [104, 101, 322, 322, 111]
iex> "hełło" <> <<0>>
# <<104, 101, 197, 130, 197, 130, 111, 0>>

# 322 é o número Unicode de ł, representado em UTF-8 pelos dois bytes 197, 130.

# Você pode obter o codepoint de um caractere usando ?
iex> ?Z
# 90

# podemos representar qualquer caractere Unicode em uma string Elixir usando a notação \u
# e a representação hexadecimal de seu número de ponto de código.
iex> "\u0061"
# "a"
iex> "\u0061" == <<97>>
# true
iex> 0x0061 == ?a
# true

# Codepoints são apenas simples caracteres Unicode representados por um ou mais bytes,
# dependendo da codificação UTF-8. Caracteres diferentes do padrão US ASCII são sempre codificados
# por mais de um byte. Por exemplo, caracteres latinos com til ou acentos (á, ñ, è) geralmente são
# codificados com dois bytes.
# Já caracteres de línguas asiáticas são normalmente codificados com três ou quatro bytes.
# Graphemes consistem de múltiplos codepoints que são apresentados como um único caractere.
iex> string = "\u0061\u0301"
# "á"
iex> String.codepoints(string)
# ["a", "́´"]
iex> String.graphemes(string)
# ["á"]

# FUNÇÕES
at(string, position)
# Retorna o grafema na posição da string UTF-8 fornecida. Se a posição for maior que o comprimento da string,
# ela retornará nil.

bag_distance(string1, string2)
# Calcula a distância do saco entre duas cordas.

capitalize(string, mode \\ :default)
# Converte o primeiro caractere na string fornecida em maiúsculas
# e o restante em minúsculas de acordo com o modo.

chunk(string, trait)
# Divide a string em pedaços de caracteres que compartilham um traço comum.

codepoints(string)
# Retorna uma lista de pontos de código codificados como strings.

contains?(string, contents)
# Verifica se a string contém algum dos conteúdos fornecidos.

downcase(string, mode \\ :default)
# Converte todos os caracteres na string fornecida em minúsculas de acordo com o modo.

duplicate(subject, n)
# Retorna um assunto de string duplicado n vezes.

ends_with?(string, suffix)
# Retorna verdadeiro se a string termina com qualquer um dos sufixos fornecidos.

equivalent?(string1, string2)
# Retorna verdadeiro se string1 for canonicamente equivalente a 'string2'.

first(string)
# Retorna o primeiro grafema de uma string UTF-8, nulo se a string estiver vazia.

graphemes(string)
# Retorna grafemas Unicode na string de acordo com o algoritmo Extended Grapheme Cluster.

jaro_distance(string1, string2)
# Calcula a distância Jaro (similaridade) entre duas strings.
# Retorna um valor flutuante entre 0.0(equivale a nenhuma semelhança) e 1.0 (é uma correspondência exata)

last(string)
# Retorna o último grafema de uma string UTF-8, nulo se a string estiver vazia.

length(string)
# Retorna o número de grafemas Unicode em uma string UTF-8.

match?(string, regex)
# Verifica se a string corresponde à expressão regular fornecida.

myers_difference(string1, string2)
# Retorna uma lista de palavras-chave que representa um script de edição.

next_codepoint(string)
# Retorna o próximo ponto de código em uma string.

next_grapheme(binary)
# Retorna o próximo grafema em uma string.

next_grapheme_size(string)
# Retorna o tamanho (em bytes) do próximo grafema.

normalize(string, form)
# Converte todos os caracteres em string para o formato de normalização Unicode identificado pelo formulário.

pad_leading(string, count, padding \\ [" "])
# Retorna uma nova string preenchida com um preenchimento inicial que é feito de elementos do preenchimento.

pad_trailing(string, count, padding \\ [" "])
# Retorna uma nova string preenchida com um preenchimento final que é feito de elementos do preenchimento.

printable?(string, character_limit \\ :infinity)
# Verifica se uma string contém apenas caracteres imprimíveis até character_limit.

replace(subject, pattern, replacement, options \\ [])
# Retorna uma nova string criada pela substituição de ocorrências de padrão no assunto por substituição.

replace_leading(string, match, replacement)
# Substitui todas as ocorrências iniciais de correspondência pela substituição de correspondência na sequência.

replace_prefix(string, match, replacement)
# Substitui o prefixo na string por substituição se corresponder.

replace_suffix(string, match, replacement)
# Substitui o sufixo na string por substituição se corresponder.

replace_trailing(string, match, replacement)
# Substitui todas as ocorrências finais de correspondência por substituição na sequência.

reverse(string)
# Inverte os grafemas em uma determinada string.

slice(string, range)
# Retorna uma substring do deslocamento fornecido pelo início do intervalo até o deslocamento fornecido pelo final do intervalo.

slice(string, start, length)
# Retorna uma substring começando no início do deslocamento e com o comprimento fornecido.

split(binary)
# Divide uma string em substrings em cada ocorrência de espaço em branco Unicode com espaços em branco
# à esquerda e à direita ignorados. Grupos de espaços em branco são tratados como uma única ocorrência.
# As divisões não ocorrem em espaços em branco ininterruptos.

split(string, pattern, options \\ [])
Divides a string into parts based on a pattern.

split_at(string, position)
Splits a string into two at the specified offset. When the offset given is negative, location is counted from the end of the string.

splitter(string, pattern, options \\ [])
Returns an enumerable that splits a string on demand.

starts_with?(string, prefix)
Returns true if string starts with any of the prefixes given.

to_atom(string)
Converts a string to an atom.

to_charlist(string)
Converts a string into a charlist.

to_existing_atom(string)
Converts a string to an existing atom.

to_float(string)
Returns a float whose text representation is string.

to_integer(string)
Returns an integer whose text representation is string.

to_integer(string, base)
Returns an integer whose text representation is string in base base.

trim(string)
Returns a string where all leading and trailing Unicode whitespaces have been removed.

trim(string, to_trim)
Returns a string where all leading and trailing to_trim characters have been removed.

trim_leading(string)
Returns a string where all leading Unicode whitespaces have been removed.

trim_leading(string, to_trim)
Returns a string where all leading to_trim characters have been removed.

trim_trailing(string)
Returns a string where all trailing Unicode whitespaces has been removed.

trim_trailing(string, to_trim)
Returns a string where all trailing to_trim characters have been removed.

upcase(string, mode \\ :default)
Converts all characters in the given string to uppercase according to mode.

valid?(string)
Checks whether string contains only valid characters.
