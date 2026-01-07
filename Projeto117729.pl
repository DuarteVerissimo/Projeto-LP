:- encoding(utf8).
% ist1117729 Duarte Veríssimo
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).

:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].



%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 1
%------------------------------------------------------------------------------------------------------------------------------------------


% Calcula a média aritmética de uma lista de valores
% Caso Base: A média de uma lista vazia é 0 (o cut (!) impede que volte atrás) 
media([], 0):-!.
media(ListaValores , Media):-
    sum_list(ListaValores, Soma),
    length(ListaValores, Num),
    Media1 is Soma / Num,
    arredonda(Media1, Media).

% Calcula a média das notas dos exames de todos os estudantes de um certo
% intervalo de idades ([IdadeMin, IdadeMax])
mediaNotasPorIdade(IdadeMin, IdadeMax, Media) :-
    % Recolhe todas as notas de alunos que estao nesse intervalo de 
    % idades e junta numa lista
    findall(Nota, (
        estudante(Id, Idade, _), 
        Idade > IdadeMin, 
        Idade =< IdadeMax, 
        exame(Id, Nota)
    ), ListaNotas),
    media(ListaNotas, Media).       % Calcula a media dessa lista

% Calcula a media da frequência de atividade física de todos os estudantes 
% de um certo género
freqPorGenero(Genero, MediaFreq) :-
    % Recolhe todas as frequências de atividade física dess género
    % e junta numa lista
    findall(Freq, (
        estudante(Id, _, Genero), 
        atividade(Id,_ ,_, Freq )
    ), 
    ListaFreq),
    media(ListaFreq, MediaFreq).        % Calcula a media dessa lista

% Devolve uma lista ordenada de IDs de alunos que tem saúde 'Fraca'
% e os seus valores de sono, exercício e saúde mental são inferiores 
% aos valores dados
alertaSaude(HorasSono, Exercicio, SaudeMental, ListaAlunos) :-
    % Recolhe os IDs dos alunos em risco de saúde e 
    % junta-os numa lista
    findall(Id, (
        estudante(Id, _, _), 
        saude(Id, HorasSonoEstudante, fraca, ExercicioEstudante, SaudeMentalEstudante),
        HorasSonoEstudante < HorasSono, 
        ExercicioEstudante < Exercicio, 
        SaudeMentalEstudante < SaudeMental
    ), ListaAlunosDesordenada),
    sort(ListaAlunosDesordenada, ListaAlunos).      % Ordena e remove IDs duplicados

% Calcula a probabilidade de um aluno com tempo de ecrã maior do que 
% HorasEcra ter uma nota maior do que Nota
probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    % Recolhe os IDs de todos Alunos que tem a nota do 
    % exame maior do que Nota e tempo de ecrã maior do que 
    % HorasEcra (Casos Favoráveis)
    findall(Id, (
        estudante(Id, _, _), 
        exame(Id, NotaEstudante), NotaEstudante > Nota, 
        atividade(Id, _, HorasEcraEstudante, _), HorasEcraEstudante > HorasEcra
    ),    ListaFavoraveis),
    length(ListaFavoraveis, NumFavoraveis),
    
    % Recolhe os IDs de todos os alunos que tem tempo de ecrã
    % maior do que HorasEcra (Casos Possíveis)
    findall(Id, (
        estudante(Id, _, _),
        atividade(Id, _, HorasEcraEstudante, _), HorasEcraEstudante > HorasEcra
    ),    ListaPossiveis),
    length(ListaPossiveis, NumPossiveis),
    
    % Probabilidade é a divisão dos 2 números se o número de casos 
    % possíveis não for 0
    (NumPossiveis > 0 -> Probabilidade1 is NumFavoraveis / NumPossiveis; Probabilidade1 = 0),
    arredonda(Probabilidade1, Probabilidade).

% Subtrai um valor de todos elementos de uma lista de valores
% Caso Base: Uma Lista vazia resulta numa lista vazia
subtraiValorDeLista([], _, []).
% Caso Recursivo: Subtrai o valor à lista e continua na cauda
subtraiValorDeLista([H|T], Valor, [H1|T1]) :- 
    H1 is H - Valor,
    subtraiValorDeLista(T, Valor, T1).

% Calcula a Soma dos quadrados de todos os elementos de uma lista
% Caso Base: A soma dos quadrados de uma lista vazia é 0
somaQuadrados([], 0).
% Caso Recursivo: Soma o quadrado da cabeça ao somatório dos quadrados da cauda
somaQuadrados([H|T], Resultado):-
    somaQuadrados(T, Soma),
    Resultado is Soma + H*H.

% Calcula o produto escalar (Soma dos produtos de todos os elementos com a mesma
% posição) de duas listas
% Caso Base: O produto escalar de duas listas vazias é 0
produtoEscalar([],[],0).
% Caso Recursivo: Soma o produto das cabeças com o produto escalar da cauda
produtoEscalar([H1|T1], [H2|T2], Resultado) :-
    produtoEscalar(T1, T2, Ac),
    Soma is H1*H2,
    Resultado is Ac + Soma.

% Calcula a correlacao de duas listas (De acordo com a formula)
correlacao(Lista1, Lista2, Resultado):-
    media(Lista1, Media1),
    media(Lista2, Media2),
    subtraiValorDeLista(Lista1, Media1, L1),
    subtraiValorDeLista(Lista2, Media2, L2),
    produtoEscalar(L1, L2, Numerador),
    somaQuadrados(L1, QuadradosL1),
    somaQuadrados(L2, QuadrdadosL2),
    RaizQuadradosL1 is sqrt(QuadradosL1),
    RaizQuadradosL2 is sqrt(QuadrdadosL2),
    Denominador is RaizQuadradosL1*RaizQuadradosL2,
    Denominador =\= 0,
    Resultado1 is Numerador / Denominador,
    arredonda(Resultado1, Resultado).

%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 2
%------------------------------------------------------------------------------------------------------------------------------------------

% Calcula o número de caractéres de uma palavra
tamanho(Palavra, Tamanho):-
    string_chars(Palavra, P),
    length(P, Tamanho).

% Devolve duas listas de caracteres das palavras 1 e 2, se ambas tiverem o mesmo
% número de caractéres
verificaECalcula(Palavra1, Palavra2, CaracteresPalavra1, CaracteresPalavra2):-
    tamanho(Palavra1, N),                           % N só unifica se tiverem o mesmo tamanho,
    tamanho(Palavra2, N),                           % caso contrário o predicado falha 
    string_chars(Palavra1, CaracteresPalavra1),
    string_chars(Palavra2, CaracteresPalavra2).

% Devolve o número de palavras de tamanho N de uma lista identificada por ID
quantasN(Id, N, Quantas):-
    lista_palavras(Id, Lista),      % Junta todas as palavras numa lista
    % Encontra todas as palavras de tamanho N pertencentes à lista, e
    % junta-as numa lista
    findall(Palavra, (
        member(Palavra, Lista), 
        tamanho(Palavra, N)
    ), ListaPalavrasTamanhoN),
    length(ListaPalavrasTamanhoN, Quantas).     % Mede o tamanho o dessa lista

% Devolve o número de palavras que começam pelo o caracter C de uma lista identificada por ID
quantasC(Id, C, Quantas):-
    lista_palavras(Id, Lista),
    % Encontra todas as palavras que começam pelo caracter C pertencentes à lista, 
    % e junta-as numa lista    
    findall(Palavra, (
        member(Palavra, Lista), 
        string_chars(Palavra, ListaP), 
        ListaP = [C|_] 
    ), ListaPalavrasCaracterC),
    length(ListaPalavrasCaracterC, Quantas).

% Apaga o primeiro caracter igual a Elemento de uma lista e devolve a nova lista,
% se Elemento não existir na lista devolve a lista original
% Caso Base: Se a Lista for vazia devole uma lista Vazia(fim da recursão)
% Se as listas não forem do mesmo tamanho o predicado falha
apagaElemento(_, [], []) :- !.

% Caso Recursivo 1: Se a cabeça da lista for igual a Elemento devolve apenas a
% cauda, removendo o elemento. O corte garante que só apaga a primeira ocorrência
apagaElemento(Elemento, [Elemento|T], T) :- !.

% Caso Recursivo 2: Se a cabeça for diferente do Elemento deixa a cabeça na lista
% nova e tenta apagar o Elemento na cauda
apagaElemento(Elemento, [H|T], [H|Resto]) :-
    apagaElemento(Elemento, T, Resto).


% Devolve uma lista ordenada de pares que contem a letra e posição onde ela se 
% encontra na palavra 
posicoesPalavra(Palavra, Posicoes):-
    string_chars(Palavra, ListaP),              % Transforma a palavra numa lista
    posicoesPalavraAux(ListaP, 1, ListaPares),
    sort(ListaPares, Posicoes).


% Predicado Auxiliar recursivo de posicoesPalavra, que devolve uma lista desorganizada
% com os pares
% Caso Base: Se a lista da palavra é vazia devolve uma lista vazia
posicoesPalavraAux([], _, []).
% Caso Recursivo: cria um par que contem a letra e a pos Atual e junta ao resultado da cauda
posicoesPalavraAux([H|T], PosInicial, [Par|RestoListaPares]) :-
    Par = (H, PosInicial),
    PosAtual is PosInicial + 1,
    posicoesPalavraAux(T, PosAtual, RestoListaPares).

% Devolve uma lista (pista) que tem 2 na posição i se a Palavra1 (mistério) tem a mesma 
% letra na posição i da Palavra2 (palpite) e 0 caso contrário
pista1(Palavra1, Palavra2, Pista):-
    verificaECalcula(Palavra1, Palavra2, ListaPalavra1, ListaPalavra2),
    pista1AUX(ListaPalavra1, ListaPalavra2, Pista).

% Predicado Auxiliar recursivo de pista1, que devole a pista
% Caso Base: Se a lista da palavra é vazia devolve uma lista vazia
pista1AUX([], [], []).
% Caso Recusivo: Compara a Cabeça das duas listas e se forem iguais adiciona 2 à lista resultante da cauda
% caso contrário adiciona 0
pista1AUX([H1|T1], [H2|T2], [N|Resto]):-
    (H1 = H2 -> N = 2
    ;
    N = 0),
    pista1AUX(T1, T2, Resto).

% Devolve uma lista (pista) que tem 2 na posição i se a Palavra1 (mistério) tem a mesma letra que a palavra2 (palpite),
% tem 1 se a letra da palavra2 existir na Palavra1 mas noutra posição, 0 caso contrário
pista2(Palavra1, Palavra2, Pista):-
    verificaECalcula(Palavra1, Palavra2, ListaPalavra1, ListaPalavra2),
    pista2AUX(ListaPalavra1, ListaPalavra2, ListaPalavra1, Pista).

% Predicado Auxiliar recursivo de pista2, que percorre as letras das duas palavras e ainda recebe a lista 
% das letras da palavra1 (mistério) para verificar se a letra existe noutra posição
% Caso Base: Se a lista da palavra é vazia devolve uma lista vazia
pista2AUX([],[], _, []).
% Caso Recursivo: Se as cabeças forem iguais adiciona 2 à lista resultante da cauda, se as cabeças forem 
% diferentes mas a cabeça da palavra2 existir na palavra1 adiciona 1 à lista resultante da cauda, caso 
% contrário adiciona 0
pista2AUX([H1|T1], [H2|T2], ListaPalavra1, [N|Resto]):-
    (
        H1 = H2 -> N = 2
    ;
        member(H2, ListaPalavra1) -> N = 1
    ;
        N = 0
    ),
    pista2AUX(T1, T2, ListaPalavra1, Resto).

% Devolve uma lista (pista) que tem 2 na posição i se a Palavra1 (mistério) tem a mesma letra que a palavra2 (palpite),
% tem 1 se a letra da palavra2 existir na Palavra1 noutra posição mas até um certo número, 0 caso contrário
pista3(Palavra1, Palavra2, Pista):-
    verificaECalcula(Palavra1, Palavra2, ListaPalavra1, ListaPalavra2),
    letrasDiferentes(ListaPalavra1, ListaPalavra2, ListaLetrasDiferentes),
    pista3AUX(ListaPalavra1, ListaPalavra2, ListaLetrasDiferentes, Pista).


% Predicado Auxiliar de pista3, que constrói uma lista com as letras de Palavra1 que estão em posições
% onde as palavras diferem
% Caso Base: Se a lista é vazia devolve uma lista vazia
letrasDiferentes([], [], []).
% Caso Recursivo: se as cabecas forem diferentes guarda o H1 (letra da palavra mistério) numa lista, caso contrário
% ignora
letrasDiferentes([H1|T1], [H2|T2], ListaFinal):-
    ( H1 \= H2 -> 
        letrasDiferentes(T1, T2 , Resto),
        ListaFinal = [H1|Resto] 
    ;
        letrasDiferentes(T1, T2, ListaFinal)
    ).

% Predicado Auxiliar de pista3, que devole a pista e recebe a lista de letras diferentes
% Caso Base: Se a lista é vazia devolve uma lista vazia
pista3AUX([], [], _, []).
% Caso Recursivo: Compara as cabeças das listas das palavras, se forem iguais adiciona 2 à lista resultante da cauda,
% se H2 existir na lista de letras diferentes adiciona 1 à lista resultante da cauda e remove H2 da lista de letras diferentes,
% caso contrário adiciona 0
pista3AUX([H1|T1], [H2|T2], ListaLetrasDiferentes, [N|Resto]):-
    ( H1 = H2 -> 
        N = 2, 
        pista3AUX(T1, T2, ListaLetrasDiferentes, Resto)
    ;
        member(H2, ListaLetrasDiferentes) ->
        apagaElemento(H2, ListaLetrasDiferentes, ListaLetrasDiferentesNova),
        N = 1, 
        pista3AUX(T1, T2, ListaLetrasDiferentesNova, Resto)
    ;
        N = 0,
        pista3AUX(T1, T2, ListaLetrasDiferentes, Resto)
    ).  

%------------------------------------------------------------------------------------------------------------------------------------------
% Parte 3
%------------------------------------------------------------------------------------------------------------------------------------------

% Predicado Principal, completa a lista filmes com 'empty' para ter 7 posições, gera permutacoes,
% filtra as restrições, ordena as programacoes validas e remove as duplicadas
maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao):-
    completaComEmpty(ListaFilmes, ListaCom7Filmes),
    findall(Programacao1,(
        permutation(ListaCom7Filmes, Programacao1), 
        verificaRestricoes(ListaRestricoes,Programacao1)
    ), ListaComRepetidos),
    sort(ListaComRepetidos, Programacao).

% Completa a lista de filmes com 'empty' ate ter 7 posicoes
completaComEmpty(ListaFilmes, ListaFilmesFinal):-
    length(ListaFilmes, Nfilmes),
    NumEmpty is 7 - Nfilmes,
    length(ListaEmptys, NumEmpty),
    maplist(=(empty), ListaEmptys),
    append([ListaFilmes, ListaEmptys], ListaFilmesFinal).

% Caso Base: Não tem restrições, é sempre verdade a programação
verificaRestricoes([],_).

% Restricao 'terror': filme de terror so pode ser nas sessoes 3,4 ou 7 (a partir das 20h)
verificaRestricoes([terror(Filme) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilmeTerror, Programacao, Filme),
    member(IndiceFilmeTerror, [3,4,7]),
    verificaRestricoes(RestoDasRestricoes, Programacao).

% Restricao 'soPode': o filme tem de estar exatamente na sessao indicada
verificaRestricoes([soPode(Filme, Sessao) | RestoDasRestricoes], Programacao):-
    nth1(Sessao, Programacao, Filme),
    verificaRestricoes(RestoDasRestricoes, Programacao).

% Restricao 'nunca': o filme nao pode estar na sessao indicada
verificaRestricoes([nunca(Filme, Sessao) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme, Programacao, Filme),
    IndiceFilme \= Sessao,
    verificaRestricoes(RestoDasRestricoes, Programacao).

% Restricao 'seguido': Filme2 deve vir imediatamente apos Filme1, no mesmo dia
verificaRestricoes([seguido(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    IndiceFilme1 \= 4,                          % Impede que estejam em dias diferentes
    1 is IndiceFilme2 - IndiceFilme1,
    verificaRestricoes(RestoDasRestricoes, Programacao).

% Restricao 'naoSeguido': Filmes nao podem ser seguidos no mesmo dia
verificaRestricoes([naoSeguido(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    (
        % Calcula a diferenca do modulo que tem de ser diferente de 1
        (ModuloDiferencaIndices is abs(IndiceFilme1 - IndiceFilme2), ModuloDiferencaIndices \= 1)
    ;
        % Possibilita que os filmes estejam em sessoes seguidas mas em dias diferentes
        ((IndiceFilme1 = 4, IndiceFilme2 = 5); (IndiceFilme1 = 5, IndiceFilme2 = 4))
    ),
    verificaRestricoes(RestoDasRestricoes, Programacao).

% Restricao 'antes': Filme1 deve vir antes de Filme2
verificaRestricoes([antes(Filme1, Filme2) | RestoDasRestricoes], Programacao):-
    nth1(IndiceFilme1, Programacao, Filme1),
    nth1(IndiceFilme2, Programacao, Filme2),
    IndiceFilme1 < IndiceFilme2,
    verificaRestricoes(RestoDasRestricoes, Programacao).
