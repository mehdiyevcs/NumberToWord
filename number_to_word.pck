create or replace package number_to_word is

  -- Author  : Mehdiyevcs
  -- Created : 7/31/2020 1:01:58 AM
  -- Purpose : Convert number to word
  
  type array_str is varray(20) of varchar2(15);
  az_num array_str := array_str(--'',
                                ' bir',
                                ' iki',
                                ' uc',
                                ' dord',
                                ' bes',
                                ' alt?',
                                ' yeddi',
                                ' s?kkiz',
                                ' doqquz',
                                ' on',
                                ' on bir',
                                ' on iki',
                                ' on uc',
                                ' on dord',
                                ' on bes',
                                ' on alt?',
                                ' on yeddi',
                                ' on s?kkiz',
                                ' on doqquz');
  
  az_tens array_str := array_str(--'',
                                 ' on',
                                 ' iyirmi',
                                 ' otuz',
                                 ' q?rx',
                                 ' ?lli',
                                 ' altm?s',
                                 ' yetmis',
                                 ' s?ks?n',
                                 ' doxsan');
  
  function convertNumToAzeri(num    number)
    return varchar2;
  function convertInt(num  integer)
    return varchar2;
  function convertLessThanOneThousand(numb number)
    return varchar2;

end number_to_word;
/
create or replace package body number_to_word is

--Main function for converting number to Azerbaijani alphabet
  function convertNumToAzeri(num    number)
    return varchar2
  is
    finalString             varchar2(1000);
  begin
    
    --Special case if amount iz zero
    if num=0 then
      return 's?f?r';
    elsif num is null then
      RAISE_APPLICATION_ERROR(-20001,'num is null');
    end if;
    
    finalString:=convertInt(num);
    
    if num<0 then
       finalString:='minus' || finalString;
    end if;
      
    --Regexpression for removing Extra Spaces
    return regexp_replace(finalString,'[ ]+',' ');
  end;
  
  
  function convertInt(num  integer)
    return varchar2
  is
  thousands        number;
  tradThous        varchar2(50);
  hundredThousands number;
  tradHund         varchar2(50);
  millions         number;
  tradMill         varchar2(50);
  billions         number;
  tradBill         varchar2(50);
  numString        varchar2(30);
  finalString      varchar2(1000);
  begin
    --mask 0000000000000000000000
    numString:=to_char(num,'9999999999999999999999');
    /*    Extra cases
    --mask 0000000xxx000000000000 trillion
    --mask 0000xxx000000000000000 quadrillion
    --mask 0xxx000000000000000000 quintillion
    --mask x000000000000000000000 sextillion
    */
    
    --mask 0000000000xxx000000000 billions
    billions:=to_number(regexp_replace(substr(numString,12,3), '[[:space:]]*',''),'9999999999999999999999');
    if billions is null then
      tradBill:='';
    else
      case billions
        when 0 then
          tradBill:='';
        else
          tradBill:=convertLessThanOneThousand(billions) || ' milyard ';
      end case;
    end if;
    finalString:=tradBill;
    
    
    --mask 0000000000000xxx000000 millions
    millions:=to_number(regexp_replace(substr(numString,15,3), '[[:space:]]*',''),'9999999999999999999999');
    if millions is null then
      tradMill:='';
    else
      case millions
        when 0 then
          tradMill:='';
        else
          tradMill:=convertLessThanOneThousand(millions) || ' milyon ';
        end case;
    end if;
    finalString:=finalString || tradMill;
    
    
    --mask 0000000000000000xxx000 hundredThousands
    hundredThousands:=nvl(to_number(regexp_replace(substr(numString,18,3), '[[:space:]]*',''),'9999999999999999999999'),'');
    if hundredThousands is null then
      tradHund:='';
    else
      case hundredThousands
        when 0 then
          tradHund:='';
        else
          tradHund:=convertLessThanOneThousand(hundredThousands) || ' min ';
        end case;
     end if;
    finalString:=finalString ||tradHund;
    
    
    --mask 0000000000000000000xxx thousands
    thousands:=nvl(to_number(regexp_replace(substr(numString,21,3), '[[:space:]]*',''),'9999999999999999999999'),'');
    tradThous:=convertLessThanOneThousand(thousands);
    finalString:=finalString || tradThous;
    return finalString;
  end;


  --Function used for converting numbers less than 1000
  --(billion, million and etc, each considered as less than 1000 and subsequent meaning is added)
  function convertLessThanOneThousand(numb number)
    return varchar2
  is
  soFar    varchar2(1000);
  num      number;
  begin
    
    --If argument is NULL return ''
    if numb is null then
      return '';
    end if;
    
    num:=numb;
    
    if mod(num,100)=0 then--case x00
      soFar:='';
      num:=Trunc(num/100);
    elsif mod(num,100) < 20 then--case x(xx<20)
      soFar:=az_num(mod(num,100));
      num:=Trunc(num/100);
    elsif mod(num,10)=0 then--case xx0
      num:=Trunc(num/10);
      soFar:=az_tens(mod(num,10));
      num:=Trunc(num/10);
    else--case xxx
      soFar:=az_num(mod(num,10));
      num:=Trunc(num/10);
      soFar:=az_tens(mod(num,10)) || soFar;
      num:=Trunc(num/10);
    end if;
    
    if num = 0 then
      return soFar;
    elsif mod(num,10)=1 then
      return  ' yuz' || soFar;
    else
      return az_num(mod(num,10)) || ' yuz' || soFar;
    end if;
  end;
end number_to_word;
/
