-module(redlib).
-compile(export_all).
%=============================================================================================================================================================================================
%                                         LISTS
%=============================================================================================================================================================================================
-spec split_list_for(List,N) -> [list()]  when
  List    :: list(),
  N       :: integer().
%*******************************************************************************************************************************
split_list_for(List,N)->split_list_for(List,[],N).
%*******************************************************************************************************************************
-spec split_list_for([any()],_,_) -> any().
%*******************************************************************************************************************************
split_list_for([],Lists,_N)->Lists;
split_list_for(List,Lists,N) when erlang:length(List)  =< N -> [List|Lists];
split_list_for(List,Lists,N) when erlang:length(List)  >  N -> {H,T} = lists:split(N,List),
  split_list_for(T,[H|Lists],N).
%=============================================================================================================================================================================================
-spec list_element(List,Elem) -> term()  when
  List       :: list(),
  Elem       :: integer().
%*****************************************************************************************************************************************************************************************
list_element(List,Elem)->element(Elem,erlang:list_to_tuple(List)).
%=============================================================================================================================================================================================
-spec list_element2([any()],pos_integer()) -> any().
list_element2(List,Elem)->erlang:hd(lists:sublist(List, Elem, 1)).
%=============================================================================================================================================================================================
-spec sort_list_of_tuple(List) -> [tuple()]  when
  List  :: [tuple()].
%*****************************************************************************************************************************************************************************************
sort_list_of_tuple([])           -> [];
sort_list_of_tuple([{Data,H}|T]) -> sort_list_of_tuple([{DataX,X} ||{DataX,X} <- T,X < H]) ++
  [{Data,H}] ++
  sort_list_of_tuple([{DataX,X} || {DataX,X} <-T ,X >= H]).
%=============================================================================================================================================================================================
-spec deduplicate(List) -> list() when
  List       :: list().
%*****************************************************************************************************************************************************************************************
deduplicate([])    -> [];
deduplicate([H|T]) -> [H|deduplicate(deduplicate(H, T))].
-spec deduplicate(_,[any()]) -> [any()].
deduplicate(X, XS) -> [Y || Y <- XS, Y =/= X].
%=============================================================================================================================================================================================
-spec deduplicate([tuple()],integer()) -> list().
%*****************************************************************************************************************************************************************************************
deduplicate([],Num)    -> [];
deduplicate([H|T],Num) -> [H|deduplicate(deduplicate(H, T,Num),Num)].
deduplicate(X, XS,Num) -> [Y || Y <- XS, element(Num,Y) =/= element(Num,X)].
%=============================================================================================================================================================================================
-spec list2binary_ex([any()]) -> binary().
%*****************************************************************************************************************************************************************************************
list2binary_ex(ListOfTerms) -> list_to_binary([list2binary_convert(E) || E <- ListOfTerms]).
list2binary_convert(X) when is_atom(X) -> atom_to_list(X);
list2binary_convert(X) when is_integer(X) -> integer_to_list(X);
list2binary_convert(X) when is_float(X) -> float_to_list(X);
list2binary_convert(X) -> X.
%=============================================================================================================================================================================================
-spec is_simple_list(maybe_improper_list()) -> boolean().
%*****************************************************************************************************************************************************************************************
is_simple_list([]) -> true;
is_simple_list([_H | _T]) when is_list(_H) -> false;
is_simple_list([_H | _T]) when is_tuple(_H) -> false;
is_simple_list([H | T]) ->
  case array:is_array(H) of
    true -> false;
    _ -> is_simple_list(T)
  end.
%=============================================================================================================================================================================================
-spec is_string(maybe_improper_list()) -> boolean().
%*****************************************************************************************************************************************************************************************
is_string([]) -> true;
is_string([H | T]) when is_integer(H) and (H < 256) -> is_string(T);
is_string([_H | _T]) -> false.
%=============================================================================================================================================================================================
%                                                  HTML
%=============================================================================================================================================================================================
-spec data_to_html(Data) -> binary()  when
  Data  :: term().
%*******************************************************************************************************************************
data_to_html(Data) when is_list(Data) ->
  case is_simple_list(Data) of
    true  -> list_to_binary(["<html><head><title></title></head><body>", Data, "</body></html>"]);
    false -> list_to_binary(["<html><head><title></title></head><body>",list_to_html_table(Data), "</body></html>"])
  end;
data_to_html(List) when is_tuple(List) -> data_to_html(tuple_to_list(List));
data_to_html(List) when is_atom(List) -> list_to_binary(["<html><head><title></title></head><body>",atom_to_list(List),"</body></html>"]);
data_to_html(_List) -> <<"Error">>.
%*****************************************************************************************************************************************************************************************
-spec list_to_html_table(maybe_improper_list(any(),binary() | [])) -> binary().
%*****************************************************************************************************************************************************************************************

list_to_html_table(List) ->
  case is_string(List) of
    true  -> list_to_binary(["<table><tr><td>",List,"</td></tr></table>"]);
    false -> list_to_html_table(List, [])
  end.
%*****************************************************************************************************************************************************************************************
-spec list_to_html_table([any()],[any()]) -> binary().
list_to_html_table([], ANS) -> list_to_binary(["<table>", lists:reverse(ANS), "</table>"]);
list_to_html_table([Head | Tail], ANS) ->list_to_html_table(Tail, [get_row(Head)| ANS]).
%*****************************************************************************************************************************************************************************************
-spec get_row(_) -> binary().
%*****************************************************************************************************************************************************************************************
get_row(Row) when is_tuple(Row)->get_row(tuple_to_list(Row));
get_row(Row) ->
  case is_list(Row) of
    true->case is_string(Row) of
            true->list_to_binary(["<tr><td>",Row,"</td></tr>"]);
            false->get_row(Row,[])
          end;
    false->list2binary_ex(["<tr><td>",Row,"</td></tr>"])
  end.
%*****************************************************************************************************************************************************************************************
-spec get_row([any()],[any()]) -> binary().
%*****************************************************************************************************************************************************************************************
get_row([],ANS)->list_to_binary(["<tr>", lists:reverse(ANS), "</tr>"]);
get_row([H|T],ANS)when is_list(H)->
  case is_string(H) of
    true  -> get_row(T,[list_to_binary(["<td>", H, "</td>"])|ANS]);
    false -> get_row(T,[list_to_binary(["<td>",list_to_html_table(H), "</td>"])|ANS])
  end;
get_row([H|T],ANS)when is_tuple(H)->get_row([tuple_to_list(H)|T],ANS); 
get_row([H|T],ANS)->get_row(T,[list2binary_ex(["<td>", H , "</td>"])|ANS]).
%====================================================================================================================================================================================
-spec absolete_append([any()]) -> list().
%*****************************************************************************************************************************************************************************************
absolete_append(LoL)->absolete_append(LoL,[],[]).
absolete_append([],Acc1,[])->lists:reverse(Acc1);
absolete_append([],Acc1,Acc2)->absolete_append(lists:append(lists:reverse(Acc2)),Acc1,[]);
absolete_append([H|T],Acc1,Acc2) when is_list(H)-> absolete_append(T,Acc1,[H|Acc2]);
absolete_append([H|T],Acc1,Acc2) when is_tuple(H)-> absolete_append(T,Acc1,[tuple_to_list(H)|Acc2]);
absolete_append([H|T],Acc1,Acc2) -> absolete_append(T,[H|Acc1],Acc2).
%====================================================================================================================================================================================
-spec drop_elements(list(),list()) -> list().
%*****************************************************************************************************************************************************************************************
drop_elements(List,Droplist)->lists:filter(fun(Elem)->not lists:member(Elem,Droplist)end,List).
%====================================================================================================================================================================================
-spec plist_set_value(atom(),term(),list()) -> list().
%*****************************************************************************************************************************************************************************************
plist_set_value(Name,Value,List)->[{Name,Value}|List].
%====================================================================================================================================================================================
