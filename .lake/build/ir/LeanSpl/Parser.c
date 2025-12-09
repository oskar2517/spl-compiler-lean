// Lean compiler output
// Module: LeanSpl.Parser
// Imports: public import Init public import Std.Internal.Parsec.String public import LeanSpl.Absyn
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
static lean_object* l_Parser_factor___closed__0;
static lean_object* l_Parser_factor___closed__6;
static lean_object* l_Parser_term_x27___closed__6;
static lean_object* l_Parser_expr_x27___closed__1;
static lean_object* l_Parser_integer___closed__3;
static lean_object* l_Parser_term_x27___closed__4;
static lean_object* l_Parser_integer___closed__0;
static lean_object* l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1;
lean_object* lean_string_utf8_byte_size(lean_object*);
lean_object* lean_string_push(lean_object*, uint32_t);
static lean_object* l_Parser_term_x27___closed__5;
LEAN_EXPORT lean_object* l_Parser_integer(lean_object*);
static lean_object* l_Parser_factor___closed__1;
lean_object* l_Std_Internal_Parsec_String_Parser_run___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Parser_expr_x27(lean_object*, lean_object*);
static lean_object* l_Parser_parseExpr___closed__0;
uint8_t lean_uint32_dec_le(uint32_t, uint32_t);
static lean_object* l_Parser_term_x27___closed__3;
static lean_object* l_Parser_expr_x27___closed__0;
static lean_object* l_Parser_factor___closed__7;
static lean_object* l_Parser_term_x27___closed__1;
LEAN_EXPORT lean_object* l_Parser_term_x27(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Parser_factor(lean_object*);
static lean_object* l_Parser_expr_x27___closed__2;
static lean_object* l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0;
LEAN_EXPORT lean_object* l_Parser_parseExpr(lean_object*);
static lean_object* l_Parser_factor___closed__5;
static lean_object* l_Parser_term_x27___closed__2;
static lean_object* l_Parser_factor___closed__2;
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
static lean_object* l_Parser_integer___closed__1;
uint8_t lean_nat_dec_lt(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_Parser_expr(lean_object*);
uint8_t lean_uint32_dec_eq(uint32_t, uint32_t);
uint32_t lean_string_utf8_get_fast(lean_object*, lean_object*);
static lean_object* l_Parser_factor___closed__3;
lean_object* l_String_toInt_x21(lean_object*);
lean_object* lean_string_utf8_next_fast(lean_object*, lean_object*);
static lean_object* l_Parser_term_x27___closed__0;
lean_object* l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(lean_object*);
static lean_object* l_Parser_term_x27___closed__7;
static lean_object* l_Parser_integer___closed__6;
LEAN_EXPORT lean_object* l_Parser_term(lean_object*);
lean_object* lean_string_append(lean_object*, lean_object*);
static lean_object* l_Parser_integer___closed__4;
lean_object* lean_int_neg(lean_object*);
LEAN_EXPORT lean_object* l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0(lean_object*, lean_object*);
static lean_object* l_Parser_factor___closed__4;
static lean_object* l_Parser_expr_x27___closed__3;
static lean_object* l_Parser_integer___closed__5;
static lean_object* l_Parser_integer___closed__2;
static lean_object* _init_l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("digit expected", 14, 14);
return x_1;
}
}
static lean_object* _init_l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_14; uint8_t x_15; 
x_3 = lean_ctor_get(x_2, 0);
x_4 = lean_ctor_get(x_2, 1);
lean_inc(x_4);
x_14 = lean_string_utf8_byte_size(x_3);
x_15 = lean_nat_dec_lt(x_4, x_14);
lean_dec(x_14);
if (x_15 == 0)
{
lean_object* x_16; 
x_16 = lean_box(0);
lean_inc(x_4);
x_5 = x_2;
x_6 = x_4;
x_7 = x_16;
goto block_11;
}
else
{
uint32_t x_17; uint32_t x_18; uint8_t x_19; 
x_17 = lean_string_utf8_get_fast(x_3, x_4);
x_18 = 48;
x_19 = lean_uint32_dec_le(x_18, x_17);
if (x_19 == 0)
{
goto block_13;
}
else
{
uint32_t x_20; uint8_t x_21; 
x_20 = 57;
x_21 = lean_uint32_dec_le(x_17, x_20);
if (x_21 == 0)
{
goto block_13;
}
else
{
uint8_t x_22; 
lean_inc_ref(x_3);
x_22 = !lean_is_exclusive(x_2);
if (x_22 == 0)
{
lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; 
x_23 = lean_ctor_get(x_2, 1);
lean_dec(x_23);
x_24 = lean_ctor_get(x_2, 0);
lean_dec(x_24);
x_25 = lean_string_utf8_next_fast(x_3, x_4);
lean_dec(x_4);
lean_ctor_set(x_2, 1, x_25);
x_26 = lean_string_push(x_1, x_17);
x_1 = x_26;
goto _start;
}
else
{
lean_object* x_28; lean_object* x_29; lean_object* x_30; 
lean_dec(x_2);
x_28 = lean_string_utf8_next_fast(x_3, x_4);
lean_dec(x_4);
x_29 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_29, 0, x_3);
lean_ctor_set(x_29, 1, x_28);
x_30 = lean_string_push(x_1, x_17);
x_1 = x_30;
x_2 = x_29;
goto _start;
}
}
}
}
block_11:
{
uint8_t x_8; 
x_8 = lean_nat_dec_eq(x_4, x_6);
lean_dec(x_6);
lean_dec(x_4);
if (x_8 == 0)
{
lean_object* x_9; 
lean_dec_ref(x_1);
x_9 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_9, 0, x_5);
lean_ctor_set(x_9, 1, x_7);
return x_9;
}
else
{
lean_object* x_10; 
lean_dec(x_7);
x_10 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_10, 0, x_5);
lean_ctor_set(x_10, 1, x_1);
return x_10;
}
}
block_13:
{
lean_object* x_12; 
x_12 = l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1;
lean_inc(x_4);
x_5 = x_2;
x_6 = x_4;
x_7 = x_12;
goto block_11;
}
}
}
static lean_object* _init_l_Parser_integer___closed__0() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("", 0, 0);
return x_1;
}
}
static lean_object* _init_l_Parser_integer___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("expected: '", 11, 11);
return x_1;
}
}
static lean_object* _init_l_Parser_integer___closed__2() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 45;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_integer___closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__2;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_integer___closed__4() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("'", 1, 1);
return x_1;
}
}
static lean_object* _init_l_Parser_integer___closed__5() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_integer___closed__3;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_integer___closed__6() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_integer___closed__5;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Parser_integer(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_6; lean_object* x_7; lean_object* x_11; lean_object* x_12; lean_object* x_13; uint8_t x_14; lean_object* x_38; lean_object* x_39; lean_object* x_40; lean_object* x_48; lean_object* x_49; lean_object* x_50; uint8_t x_51; 
x_38 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_1);
x_48 = lean_ctor_get(x_38, 0);
lean_inc_ref(x_48);
x_49 = lean_ctor_get(x_38, 1);
lean_inc(x_49);
x_50 = lean_string_utf8_byte_size(x_48);
x_51 = lean_nat_dec_lt(x_49, x_50);
lean_dec(x_50);
if (x_51 == 0)
{
lean_object* x_52; 
lean_dec(x_49);
lean_dec_ref(x_48);
x_52 = lean_box(0);
lean_inc_ref(x_38);
x_39 = x_38;
x_40 = x_52;
goto block_47;
}
else
{
uint32_t x_53; uint32_t x_54; uint8_t x_55; 
x_53 = 45;
x_54 = lean_string_utf8_get_fast(x_48, x_49);
x_55 = lean_uint32_dec_eq(x_54, x_53);
if (x_55 == 0)
{
lean_object* x_56; 
lean_dec(x_49);
lean_dec_ref(x_48);
x_56 = l_Parser_integer___closed__6;
lean_inc_ref(x_38);
x_39 = x_38;
x_40 = x_56;
goto block_47;
}
else
{
uint8_t x_57; 
x_57 = !lean_is_exclusive(x_38);
if (x_57 == 0)
{
lean_object* x_58; lean_object* x_59; lean_object* x_60; 
x_58 = lean_ctor_get(x_38, 1);
lean_dec(x_58);
x_59 = lean_ctor_get(x_38, 0);
lean_dec(x_59);
x_60 = lean_string_utf8_next_fast(x_48, x_49);
lean_dec(x_49);
lean_inc(x_60);
lean_inc_ref(x_48);
lean_ctor_set(x_38, 1, x_60);
x_11 = x_38;
x_12 = x_48;
x_13 = x_60;
x_14 = x_51;
goto block_37;
}
else
{
lean_object* x_61; lean_object* x_62; 
lean_dec(x_38);
x_61 = lean_string_utf8_next_fast(x_48, x_49);
lean_dec(x_49);
lean_inc(x_61);
lean_inc_ref(x_48);
x_62 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_62, 0, x_48);
lean_ctor_set(x_62, 1, x_61);
x_11 = x_62;
x_12 = x_48;
x_13 = x_61;
x_14 = x_51;
goto block_37;
}
}
}
block_5:
{
lean_object* x_3; lean_object* x_4; 
x_3 = l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1;
x_4 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_4, 0, x_2);
lean_ctor_set(x_4, 1, x_3);
return x_4;
}
block_10:
{
lean_object* x_8; lean_object* x_9; 
x_8 = lean_alloc_ctor(2, 1, 0);
lean_ctor_set(x_8, 0, x_7);
x_9 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_9, 0, x_6);
lean_ctor_set(x_9, 1, x_8);
return x_9;
}
block_37:
{
lean_object* x_15; uint8_t x_16; 
x_15 = lean_string_utf8_byte_size(x_12);
x_16 = lean_nat_dec_lt(x_13, x_15);
lean_dec(x_15);
if (x_16 == 0)
{
lean_object* x_17; lean_object* x_18; 
lean_dec(x_13);
lean_dec_ref(x_12);
x_17 = lean_box(0);
x_18 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_18, 0, x_11);
lean_ctor_set(x_18, 1, x_17);
return x_18;
}
else
{
uint32_t x_19; uint32_t x_20; uint8_t x_21; 
x_19 = lean_string_utf8_get_fast(x_12, x_13);
x_20 = 48;
x_21 = lean_uint32_dec_le(x_20, x_19);
if (x_21 == 0)
{
lean_dec(x_13);
lean_dec_ref(x_12);
x_2 = x_11;
goto block_5;
}
else
{
uint32_t x_22; uint8_t x_23; 
x_22 = 57;
x_23 = lean_uint32_dec_le(x_19, x_22);
if (x_23 == 0)
{
lean_dec(x_13);
lean_dec_ref(x_12);
x_2 = x_11;
goto block_5;
}
else
{
lean_object* x_24; lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_28; 
lean_dec_ref(x_11);
x_24 = lean_string_utf8_next_fast(x_12, x_13);
lean_dec(x_13);
x_25 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_25, 0, x_12);
lean_ctor_set(x_25, 1, x_24);
x_26 = l_Parser_integer___closed__0;
x_27 = lean_string_push(x_26, x_19);
x_28 = l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0(x_27, x_25);
if (lean_obj_tag(x_28) == 0)
{
lean_object* x_29; lean_object* x_30; lean_object* x_31; 
x_29 = lean_ctor_get(x_28, 0);
lean_inc(x_29);
x_30 = lean_ctor_get(x_28, 1);
lean_inc(x_30);
lean_dec_ref(x_28);
x_31 = l_String_toInt_x21(x_30);
if (x_14 == 0)
{
x_6 = x_29;
x_7 = x_31;
goto block_10;
}
else
{
lean_object* x_32; 
x_32 = lean_int_neg(x_31);
lean_dec(x_31);
x_6 = x_29;
x_7 = x_32;
goto block_10;
}
}
else
{
uint8_t x_33; 
x_33 = !lean_is_exclusive(x_28);
if (x_33 == 0)
{
return x_28;
}
else
{
lean_object* x_34; lean_object* x_35; lean_object* x_36; 
x_34 = lean_ctor_get(x_28, 0);
x_35 = lean_ctor_get(x_28, 1);
lean_inc(x_35);
lean_inc(x_34);
lean_dec(x_28);
x_36 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_36, 0, x_34);
lean_ctor_set(x_36, 1, x_35);
return x_36;
}
}
}
}
}
}
block_47:
{
lean_object* x_41; lean_object* x_42; lean_object* x_43; uint8_t x_44; 
x_41 = lean_ctor_get(x_38, 1);
lean_inc(x_41);
lean_dec_ref(x_38);
x_42 = lean_ctor_get(x_39, 0);
x_43 = lean_ctor_get(x_39, 1);
x_44 = lean_nat_dec_eq(x_41, x_43);
lean_dec(x_41);
if (x_44 == 0)
{
lean_object* x_45; 
x_45 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_45, 0, x_39);
lean_ctor_set(x_45, 1, x_40);
return x_45;
}
else
{
uint8_t x_46; 
lean_inc(x_43);
lean_inc_ref(x_42);
lean_dec(x_40);
x_46 = 0;
x_11 = x_39;
x_12 = x_42;
x_13 = x_43;
x_14 = x_46;
goto block_37;
}
}
}
}
LEAN_EXPORT lean_object* l_Parser_expr(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_Parser_term(x_1);
if (lean_obj_tag(x_2) == 0)
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; 
x_3 = lean_ctor_get(x_2, 0);
lean_inc(x_3);
x_4 = lean_ctor_get(x_2, 1);
lean_inc(x_4);
lean_dec_ref(x_2);
x_5 = l_Parser_expr_x27(x_4, x_3);
return x_5;
}
else
{
return x_2;
}
}
}
static lean_object* _init_l_Parser_expr_x27___closed__0() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 43;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_expr_x27___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_expr_x27___closed__0;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_expr_x27___closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_expr_x27___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_expr_x27___closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_expr_x27___closed__2;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Parser_expr_x27(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_21; lean_object* x_22; lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_70; lean_object* x_71; lean_object* x_74; lean_object* x_77; lean_object* x_78; lean_object* x_79; uint8_t x_80; 
x_25 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_2);
x_77 = lean_ctor_get(x_25, 0);
lean_inc_ref(x_77);
x_78 = lean_ctor_get(x_25, 1);
lean_inc(x_78);
x_79 = lean_string_utf8_byte_size(x_77);
x_80 = lean_nat_dec_lt(x_78, x_79);
lean_dec(x_79);
if (x_80 == 0)
{
lean_object* x_81; 
lean_dec(x_78);
lean_dec_ref(x_77);
x_81 = lean_box(0);
lean_inc_ref(x_25);
x_70 = x_25;
x_71 = x_81;
goto block_73;
}
else
{
uint32_t x_82; uint32_t x_83; uint8_t x_84; 
x_82 = 43;
x_83 = lean_string_utf8_get_fast(x_77, x_78);
x_84 = lean_uint32_dec_eq(x_83, x_82);
if (x_84 == 0)
{
lean_object* x_85; 
lean_dec(x_78);
lean_dec_ref(x_77);
x_85 = l_Parser_expr_x27___closed__3;
lean_inc_ref(x_25);
x_70 = x_25;
x_71 = x_85;
goto block_73;
}
else
{
lean_object* x_86; lean_object* x_87; lean_object* x_88; 
x_86 = lean_string_utf8_next_fast(x_77, x_78);
lean_dec(x_78);
x_87 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_87, 0, x_77);
lean_ctor_set(x_87, 1, x_86);
x_88 = l_Parser_term(x_87);
if (lean_obj_tag(x_88) == 0)
{
lean_object* x_89; lean_object* x_90; uint8_t x_91; lean_object* x_92; lean_object* x_93; lean_object* x_94; 
x_89 = lean_ctor_get(x_88, 0);
lean_inc(x_89);
x_90 = lean_ctor_get(x_88, 1);
lean_inc(x_90);
lean_dec_ref(x_88);
x_91 = 0;
lean_inc_ref(x_1);
x_92 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_92, 0, x_1);
lean_ctor_set(x_92, 1, x_90);
lean_ctor_set_uint8(x_92, sizeof(void*)*2, x_91);
x_93 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_93, 0, x_92);
x_94 = l_Parser_expr_x27(x_93, x_89);
x_74 = x_94;
goto block_76;
}
else
{
x_74 = x_88;
goto block_76;
}
}
}
block_15:
{
uint8_t x_6; 
x_6 = !lean_is_exclusive(x_3);
if (x_6 == 0)
{
lean_object* x_7; lean_object* x_8; lean_object* x_9; uint8_t x_10; 
x_7 = lean_ctor_get(x_3, 1);
x_8 = lean_ctor_get(x_3, 0);
lean_dec(x_8);
x_9 = lean_ctor_get(x_5, 1);
x_10 = lean_nat_dec_eq(x_7, x_9);
lean_dec(x_7);
if (x_10 == 0)
{
lean_free_object(x_3);
lean_dec_ref(x_5);
lean_dec_ref(x_1);
return x_4;
}
else
{
lean_dec_ref(x_4);
lean_ctor_set(x_3, 1, x_1);
lean_ctor_set(x_3, 0, x_5);
return x_3;
}
}
else
{
lean_object* x_11; lean_object* x_12; uint8_t x_13; 
x_11 = lean_ctor_get(x_3, 1);
lean_inc(x_11);
lean_dec(x_3);
x_12 = lean_ctor_get(x_5, 1);
x_13 = lean_nat_dec_eq(x_11, x_12);
lean_dec(x_11);
if (x_13 == 0)
{
lean_dec_ref(x_5);
lean_dec_ref(x_1);
return x_4;
}
else
{
lean_object* x_14; 
lean_dec_ref(x_4);
x_14 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_14, 0, x_5);
lean_ctor_set(x_14, 1, x_1);
return x_14;
}
}
}
block_20:
{
lean_object* x_19; 
lean_inc_ref(x_17);
x_19 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_19, 0, x_17);
lean_ctor_set(x_19, 1, x_18);
x_3 = x_16;
x_4 = x_19;
x_5 = x_17;
goto block_15;
}
block_24:
{
if (lean_obj_tag(x_22) == 0)
{
lean_dec_ref(x_21);
lean_dec_ref(x_1);
return x_22;
}
else
{
lean_object* x_23; 
x_23 = lean_ctor_get(x_22, 0);
lean_inc(x_23);
x_3 = x_21;
x_4 = x_22;
x_5 = x_23;
goto block_15;
}
}
block_69:
{
uint8_t x_28; 
x_28 = !lean_is_exclusive(x_25);
if (x_28 == 0)
{
lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; uint8_t x_33; 
x_29 = lean_ctor_get(x_25, 1);
x_30 = lean_ctor_get(x_25, 0);
lean_dec(x_30);
x_31 = lean_ctor_get(x_27, 0);
x_32 = lean_ctor_get(x_27, 1);
x_33 = lean_nat_dec_eq(x_29, x_32);
lean_dec(x_29);
if (x_33 == 0)
{
lean_free_object(x_25);
lean_dec_ref(x_27);
lean_dec_ref(x_1);
return x_26;
}
else
{
lean_object* x_34; uint8_t x_35; 
lean_dec_ref(x_26);
x_34 = lean_string_utf8_byte_size(x_31);
x_35 = lean_nat_dec_lt(x_32, x_34);
lean_dec(x_34);
if (x_35 == 0)
{
lean_object* x_36; 
lean_free_object(x_25);
x_36 = lean_box(0);
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_36;
goto block_20;
}
else
{
uint32_t x_37; uint32_t x_38; uint8_t x_39; 
x_37 = 45;
x_38 = lean_string_utf8_get_fast(x_31, x_32);
x_39 = lean_uint32_dec_eq(x_38, x_37);
if (x_39 == 0)
{
lean_object* x_40; 
lean_free_object(x_25);
x_40 = l_Parser_integer___closed__6;
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_40;
goto block_20;
}
else
{
lean_object* x_41; lean_object* x_42; 
x_41 = lean_string_utf8_next_fast(x_31, x_32);
lean_inc_ref(x_31);
lean_ctor_set(x_25, 1, x_41);
lean_ctor_set(x_25, 0, x_31);
x_42 = l_Parser_term(x_25);
if (lean_obj_tag(x_42) == 0)
{
lean_object* x_43; lean_object* x_44; uint8_t x_45; lean_object* x_46; lean_object* x_47; lean_object* x_48; 
x_43 = lean_ctor_get(x_42, 0);
lean_inc(x_43);
x_44 = lean_ctor_get(x_42, 1);
lean_inc(x_44);
lean_dec_ref(x_42);
x_45 = 1;
lean_inc_ref(x_1);
x_46 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_46, 0, x_1);
lean_ctor_set(x_46, 1, x_44);
lean_ctor_set_uint8(x_46, sizeof(void*)*2, x_45);
x_47 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_47, 0, x_46);
x_48 = l_Parser_expr_x27(x_47, x_43);
x_21 = x_27;
x_22 = x_48;
goto block_24;
}
else
{
x_21 = x_27;
x_22 = x_42;
goto block_24;
}
}
}
}
}
else
{
lean_object* x_49; lean_object* x_50; lean_object* x_51; uint8_t x_52; 
x_49 = lean_ctor_get(x_25, 1);
lean_inc(x_49);
lean_dec(x_25);
x_50 = lean_ctor_get(x_27, 0);
x_51 = lean_ctor_get(x_27, 1);
x_52 = lean_nat_dec_eq(x_49, x_51);
lean_dec(x_49);
if (x_52 == 0)
{
lean_dec_ref(x_27);
lean_dec_ref(x_1);
return x_26;
}
else
{
lean_object* x_53; uint8_t x_54; 
lean_dec_ref(x_26);
x_53 = lean_string_utf8_byte_size(x_50);
x_54 = lean_nat_dec_lt(x_51, x_53);
lean_dec(x_53);
if (x_54 == 0)
{
lean_object* x_55; 
x_55 = lean_box(0);
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_55;
goto block_20;
}
else
{
uint32_t x_56; uint32_t x_57; uint8_t x_58; 
x_56 = 45;
x_57 = lean_string_utf8_get_fast(x_50, x_51);
x_58 = lean_uint32_dec_eq(x_57, x_56);
if (x_58 == 0)
{
lean_object* x_59; 
x_59 = l_Parser_integer___closed__6;
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_59;
goto block_20;
}
else
{
lean_object* x_60; lean_object* x_61; lean_object* x_62; 
x_60 = lean_string_utf8_next_fast(x_50, x_51);
lean_inc_ref(x_50);
x_61 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_61, 0, x_50);
lean_ctor_set(x_61, 1, x_60);
x_62 = l_Parser_term(x_61);
if (lean_obj_tag(x_62) == 0)
{
lean_object* x_63; lean_object* x_64; uint8_t x_65; lean_object* x_66; lean_object* x_67; lean_object* x_68; 
x_63 = lean_ctor_get(x_62, 0);
lean_inc(x_63);
x_64 = lean_ctor_get(x_62, 1);
lean_inc(x_64);
lean_dec_ref(x_62);
x_65 = 1;
lean_inc_ref(x_1);
x_66 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_66, 0, x_1);
lean_ctor_set(x_66, 1, x_64);
lean_ctor_set_uint8(x_66, sizeof(void*)*2, x_65);
x_67 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_67, 0, x_66);
x_68 = l_Parser_expr_x27(x_67, x_63);
x_21 = x_27;
x_22 = x_68;
goto block_24;
}
else
{
x_21 = x_27;
x_22 = x_62;
goto block_24;
}
}
}
}
}
}
block_73:
{
lean_object* x_72; 
lean_inc_ref(x_70);
x_72 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_72, 0, x_70);
lean_ctor_set(x_72, 1, x_71);
x_26 = x_72;
x_27 = x_70;
goto block_69;
}
block_76:
{
if (lean_obj_tag(x_74) == 0)
{
lean_dec_ref(x_25);
lean_dec_ref(x_1);
return x_74;
}
else
{
lean_object* x_75; 
x_75 = lean_ctor_get(x_74, 0);
lean_inc(x_75);
x_26 = x_74;
x_27 = x_75;
goto block_69;
}
}
}
}
LEAN_EXPORT lean_object* l_Parser_term(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_Parser_factor(x_1);
if (lean_obj_tag(x_2) == 0)
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; 
x_3 = lean_ctor_get(x_2, 0);
lean_inc(x_3);
x_4 = lean_ctor_get(x_2, 1);
lean_inc(x_4);
lean_dec_ref(x_2);
x_5 = l_Parser_term_x27(x_4, x_3);
return x_5;
}
else
{
return x_2;
}
}
}
static lean_object* _init_l_Parser_term_x27___closed__0() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 47;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_term_x27___closed__0;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_term_x27___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_term_x27___closed__2;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l_Parser_term_x27___closed__4() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 42;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__5() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_term_x27___closed__4;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__6() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_term_x27___closed__5;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_term_x27___closed__7() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_term_x27___closed__6;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Parser_term_x27(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_21; lean_object* x_22; lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_70; lean_object* x_71; lean_object* x_74; lean_object* x_77; lean_object* x_78; lean_object* x_79; uint8_t x_80; 
x_25 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_2);
x_77 = lean_ctor_get(x_25, 0);
lean_inc_ref(x_77);
x_78 = lean_ctor_get(x_25, 1);
lean_inc(x_78);
x_79 = lean_string_utf8_byte_size(x_77);
x_80 = lean_nat_dec_lt(x_78, x_79);
lean_dec(x_79);
if (x_80 == 0)
{
lean_object* x_81; 
lean_dec(x_78);
lean_dec_ref(x_77);
x_81 = lean_box(0);
lean_inc_ref(x_25);
x_70 = x_25;
x_71 = x_81;
goto block_73;
}
else
{
uint32_t x_82; uint32_t x_83; uint8_t x_84; 
x_82 = 42;
x_83 = lean_string_utf8_get_fast(x_77, x_78);
x_84 = lean_uint32_dec_eq(x_83, x_82);
if (x_84 == 0)
{
lean_object* x_85; 
lean_dec(x_78);
lean_dec_ref(x_77);
x_85 = l_Parser_term_x27___closed__7;
lean_inc_ref(x_25);
x_70 = x_25;
x_71 = x_85;
goto block_73;
}
else
{
lean_object* x_86; lean_object* x_87; lean_object* x_88; 
x_86 = lean_string_utf8_next_fast(x_77, x_78);
lean_dec(x_78);
x_87 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_87, 0, x_77);
lean_ctor_set(x_87, 1, x_86);
x_88 = l_Parser_factor(x_87);
if (lean_obj_tag(x_88) == 0)
{
lean_object* x_89; lean_object* x_90; uint8_t x_91; lean_object* x_92; lean_object* x_93; lean_object* x_94; 
x_89 = lean_ctor_get(x_88, 0);
lean_inc(x_89);
x_90 = lean_ctor_get(x_88, 1);
lean_inc(x_90);
lean_dec_ref(x_88);
x_91 = 2;
lean_inc_ref(x_1);
x_92 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_92, 0, x_1);
lean_ctor_set(x_92, 1, x_90);
lean_ctor_set_uint8(x_92, sizeof(void*)*2, x_91);
x_93 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_93, 0, x_92);
x_94 = l_Parser_term_x27(x_93, x_89);
x_74 = x_94;
goto block_76;
}
else
{
x_74 = x_88;
goto block_76;
}
}
}
block_15:
{
uint8_t x_6; 
x_6 = !lean_is_exclusive(x_3);
if (x_6 == 0)
{
lean_object* x_7; lean_object* x_8; lean_object* x_9; uint8_t x_10; 
x_7 = lean_ctor_get(x_3, 1);
x_8 = lean_ctor_get(x_3, 0);
lean_dec(x_8);
x_9 = lean_ctor_get(x_5, 1);
x_10 = lean_nat_dec_eq(x_7, x_9);
lean_dec(x_7);
if (x_10 == 0)
{
lean_free_object(x_3);
lean_dec_ref(x_5);
lean_dec_ref(x_1);
return x_4;
}
else
{
lean_dec_ref(x_4);
lean_ctor_set(x_3, 1, x_1);
lean_ctor_set(x_3, 0, x_5);
return x_3;
}
}
else
{
lean_object* x_11; lean_object* x_12; uint8_t x_13; 
x_11 = lean_ctor_get(x_3, 1);
lean_inc(x_11);
lean_dec(x_3);
x_12 = lean_ctor_get(x_5, 1);
x_13 = lean_nat_dec_eq(x_11, x_12);
lean_dec(x_11);
if (x_13 == 0)
{
lean_dec_ref(x_5);
lean_dec_ref(x_1);
return x_4;
}
else
{
lean_object* x_14; 
lean_dec_ref(x_4);
x_14 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_14, 0, x_5);
lean_ctor_set(x_14, 1, x_1);
return x_14;
}
}
}
block_20:
{
lean_object* x_19; 
lean_inc_ref(x_17);
x_19 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_19, 0, x_17);
lean_ctor_set(x_19, 1, x_18);
x_3 = x_16;
x_4 = x_19;
x_5 = x_17;
goto block_15;
}
block_24:
{
if (lean_obj_tag(x_22) == 0)
{
lean_dec_ref(x_21);
lean_dec_ref(x_1);
return x_22;
}
else
{
lean_object* x_23; 
x_23 = lean_ctor_get(x_22, 0);
lean_inc(x_23);
x_3 = x_21;
x_4 = x_22;
x_5 = x_23;
goto block_15;
}
}
block_69:
{
uint8_t x_28; 
x_28 = !lean_is_exclusive(x_25);
if (x_28 == 0)
{
lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; uint8_t x_33; 
x_29 = lean_ctor_get(x_25, 1);
x_30 = lean_ctor_get(x_25, 0);
lean_dec(x_30);
x_31 = lean_ctor_get(x_27, 0);
x_32 = lean_ctor_get(x_27, 1);
x_33 = lean_nat_dec_eq(x_29, x_32);
lean_dec(x_29);
if (x_33 == 0)
{
lean_free_object(x_25);
lean_dec_ref(x_27);
lean_dec_ref(x_1);
return x_26;
}
else
{
lean_object* x_34; uint8_t x_35; 
lean_dec_ref(x_26);
x_34 = lean_string_utf8_byte_size(x_31);
x_35 = lean_nat_dec_lt(x_32, x_34);
lean_dec(x_34);
if (x_35 == 0)
{
lean_object* x_36; 
lean_free_object(x_25);
x_36 = lean_box(0);
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_36;
goto block_20;
}
else
{
uint32_t x_37; uint32_t x_38; uint8_t x_39; 
x_37 = 47;
x_38 = lean_string_utf8_get_fast(x_31, x_32);
x_39 = lean_uint32_dec_eq(x_38, x_37);
if (x_39 == 0)
{
lean_object* x_40; 
lean_free_object(x_25);
x_40 = l_Parser_term_x27___closed__3;
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_40;
goto block_20;
}
else
{
lean_object* x_41; lean_object* x_42; 
x_41 = lean_string_utf8_next_fast(x_31, x_32);
lean_inc_ref(x_31);
lean_ctor_set(x_25, 1, x_41);
lean_ctor_set(x_25, 0, x_31);
x_42 = l_Parser_factor(x_25);
if (lean_obj_tag(x_42) == 0)
{
lean_object* x_43; lean_object* x_44; uint8_t x_45; lean_object* x_46; lean_object* x_47; lean_object* x_48; 
x_43 = lean_ctor_get(x_42, 0);
lean_inc(x_43);
x_44 = lean_ctor_get(x_42, 1);
lean_inc(x_44);
lean_dec_ref(x_42);
x_45 = 3;
lean_inc_ref(x_1);
x_46 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_46, 0, x_1);
lean_ctor_set(x_46, 1, x_44);
lean_ctor_set_uint8(x_46, sizeof(void*)*2, x_45);
x_47 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_47, 0, x_46);
x_48 = l_Parser_term_x27(x_47, x_43);
x_21 = x_27;
x_22 = x_48;
goto block_24;
}
else
{
x_21 = x_27;
x_22 = x_42;
goto block_24;
}
}
}
}
}
else
{
lean_object* x_49; lean_object* x_50; lean_object* x_51; uint8_t x_52; 
x_49 = lean_ctor_get(x_25, 1);
lean_inc(x_49);
lean_dec(x_25);
x_50 = lean_ctor_get(x_27, 0);
x_51 = lean_ctor_get(x_27, 1);
x_52 = lean_nat_dec_eq(x_49, x_51);
lean_dec(x_49);
if (x_52 == 0)
{
lean_dec_ref(x_27);
lean_dec_ref(x_1);
return x_26;
}
else
{
lean_object* x_53; uint8_t x_54; 
lean_dec_ref(x_26);
x_53 = lean_string_utf8_byte_size(x_50);
x_54 = lean_nat_dec_lt(x_51, x_53);
lean_dec(x_53);
if (x_54 == 0)
{
lean_object* x_55; 
x_55 = lean_box(0);
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_55;
goto block_20;
}
else
{
uint32_t x_56; uint32_t x_57; uint8_t x_58; 
x_56 = 47;
x_57 = lean_string_utf8_get_fast(x_50, x_51);
x_58 = lean_uint32_dec_eq(x_57, x_56);
if (x_58 == 0)
{
lean_object* x_59; 
x_59 = l_Parser_term_x27___closed__3;
lean_inc_ref(x_27);
x_16 = x_27;
x_17 = x_27;
x_18 = x_59;
goto block_20;
}
else
{
lean_object* x_60; lean_object* x_61; lean_object* x_62; 
x_60 = lean_string_utf8_next_fast(x_50, x_51);
lean_inc_ref(x_50);
x_61 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_61, 0, x_50);
lean_ctor_set(x_61, 1, x_60);
x_62 = l_Parser_factor(x_61);
if (lean_obj_tag(x_62) == 0)
{
lean_object* x_63; lean_object* x_64; uint8_t x_65; lean_object* x_66; lean_object* x_67; lean_object* x_68; 
x_63 = lean_ctor_get(x_62, 0);
lean_inc(x_63);
x_64 = lean_ctor_get(x_62, 1);
lean_inc(x_64);
lean_dec_ref(x_62);
x_65 = 3;
lean_inc_ref(x_1);
x_66 = lean_alloc_ctor(0, 2, 1);
lean_ctor_set(x_66, 0, x_1);
lean_ctor_set(x_66, 1, x_64);
lean_ctor_set_uint8(x_66, sizeof(void*)*2, x_65);
x_67 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_67, 0, x_66);
x_68 = l_Parser_term_x27(x_67, x_63);
x_21 = x_27;
x_22 = x_68;
goto block_24;
}
else
{
x_21 = x_27;
x_22 = x_62;
goto block_24;
}
}
}
}
}
}
block_73:
{
lean_object* x_72; 
lean_inc_ref(x_70);
x_72 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_72, 0, x_70);
lean_ctor_set(x_72, 1, x_71);
x_26 = x_72;
x_27 = x_70;
goto block_69;
}
block_76:
{
if (lean_obj_tag(x_74) == 0)
{
lean_dec_ref(x_25);
lean_dec_ref(x_1);
return x_74;
}
else
{
lean_object* x_75; 
x_75 = lean_ctor_get(x_74, 0);
lean_inc(x_75);
x_26 = x_74;
x_27 = x_75;
goto block_69;
}
}
}
}
static lean_object* _init_l_Parser_factor___closed__0() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 40;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_factor___closed__0;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_factor___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_factor___closed__2;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l_Parser_factor___closed__4() {
_start:
{
uint32_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 41;
x_2 = l_Parser_integer___closed__0;
x_3 = lean_string_push(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__5() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_factor___closed__4;
x_2 = l_Parser_integer___closed__1;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__6() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l_Parser_integer___closed__4;
x_2 = l_Parser_factor___closed__5;
x_3 = lean_string_append(x_2, x_1);
return x_3;
}
}
static lean_object* _init_l_Parser_factor___closed__7() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_Parser_factor___closed__6;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_Parser_factor(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; lean_object* x_4; lean_object* x_10; lean_object* x_11; lean_object* x_14; lean_object* x_15; lean_object* x_16; uint8_t x_17; 
x_2 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_1);
x_14 = lean_ctor_get(x_2, 0);
lean_inc_ref(x_14);
x_15 = lean_ctor_get(x_2, 1);
lean_inc(x_15);
x_16 = lean_string_utf8_byte_size(x_14);
x_17 = lean_nat_dec_lt(x_15, x_16);
lean_dec(x_16);
if (x_17 == 0)
{
lean_object* x_18; 
lean_dec(x_15);
lean_dec_ref(x_14);
x_18 = lean_box(0);
lean_inc_ref(x_2);
x_10 = x_2;
x_11 = x_18;
goto block_13;
}
else
{
uint32_t x_19; uint32_t x_20; uint8_t x_21; 
x_19 = 40;
x_20 = lean_string_utf8_get_fast(x_14, x_15);
x_21 = lean_uint32_dec_eq(x_20, x_19);
if (x_21 == 0)
{
lean_object* x_22; 
lean_dec(x_15);
lean_dec_ref(x_14);
x_22 = l_Parser_factor___closed__3;
lean_inc_ref(x_2);
x_10 = x_2;
x_11 = x_22;
goto block_13;
}
else
{
lean_object* x_23; lean_object* x_24; lean_object* x_25; 
x_23 = lean_string_utf8_next_fast(x_14, x_15);
lean_dec(x_15);
x_24 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_24, 0, x_14);
lean_ctor_set(x_24, 1, x_23);
x_25 = l_Parser_expr(x_24);
if (lean_obj_tag(x_25) == 0)
{
uint8_t x_26; 
x_26 = !lean_is_exclusive(x_25);
if (x_26 == 0)
{
lean_object* x_27; lean_object* x_28; lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; uint8_t x_33; 
x_27 = lean_ctor_get(x_25, 0);
x_28 = lean_ctor_get(x_25, 1);
x_29 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_27);
x_30 = lean_ctor_get(x_29, 0);
lean_inc_ref(x_30);
x_31 = lean_ctor_get(x_29, 1);
lean_inc(x_31);
x_32 = lean_string_utf8_byte_size(x_30);
x_33 = lean_nat_dec_lt(x_31, x_32);
lean_dec(x_32);
if (x_33 == 0)
{
lean_object* x_34; 
lean_dec(x_31);
lean_dec_ref(x_30);
lean_dec(x_28);
x_34 = lean_box(0);
lean_inc_ref(x_29);
lean_ctor_set_tag(x_25, 1);
lean_ctor_set(x_25, 1, x_34);
lean_ctor_set(x_25, 0, x_29);
x_3 = x_25;
x_4 = x_29;
goto block_9;
}
else
{
uint32_t x_35; uint32_t x_36; uint8_t x_37; 
x_35 = 41;
x_36 = lean_string_utf8_get_fast(x_30, x_31);
x_37 = lean_uint32_dec_eq(x_36, x_35);
if (x_37 == 0)
{
lean_object* x_38; 
lean_dec(x_31);
lean_dec_ref(x_30);
lean_dec(x_28);
x_38 = l_Parser_factor___closed__7;
lean_inc_ref(x_29);
lean_ctor_set_tag(x_25, 1);
lean_ctor_set(x_25, 1, x_38);
lean_ctor_set(x_25, 0, x_29);
x_3 = x_25;
x_4 = x_29;
goto block_9;
}
else
{
uint8_t x_39; 
lean_dec_ref(x_2);
x_39 = !lean_is_exclusive(x_29);
if (x_39 == 0)
{
lean_object* x_40; lean_object* x_41; lean_object* x_42; 
x_40 = lean_ctor_get(x_29, 1);
lean_dec(x_40);
x_41 = lean_ctor_get(x_29, 0);
lean_dec(x_41);
x_42 = lean_string_utf8_next_fast(x_30, x_31);
lean_dec(x_31);
lean_ctor_set(x_29, 1, x_42);
lean_ctor_set(x_25, 0, x_29);
return x_25;
}
else
{
lean_object* x_43; lean_object* x_44; 
lean_dec(x_29);
x_43 = lean_string_utf8_next_fast(x_30, x_31);
lean_dec(x_31);
x_44 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_44, 0, x_30);
lean_ctor_set(x_44, 1, x_43);
lean_ctor_set(x_25, 0, x_44);
return x_25;
}
}
}
}
else
{
lean_object* x_45; lean_object* x_46; lean_object* x_47; lean_object* x_48; lean_object* x_49; lean_object* x_50; uint8_t x_51; 
x_45 = lean_ctor_get(x_25, 0);
x_46 = lean_ctor_get(x_25, 1);
lean_inc(x_46);
lean_inc(x_45);
lean_dec(x_25);
x_47 = l___private_Std_Internal_Parsec_String_0__Std_Internal_Parsec_String_skipWs(x_45);
x_48 = lean_ctor_get(x_47, 0);
lean_inc_ref(x_48);
x_49 = lean_ctor_get(x_47, 1);
lean_inc(x_49);
x_50 = lean_string_utf8_byte_size(x_48);
x_51 = lean_nat_dec_lt(x_49, x_50);
lean_dec(x_50);
if (x_51 == 0)
{
lean_object* x_52; lean_object* x_53; 
lean_dec(x_49);
lean_dec_ref(x_48);
lean_dec(x_46);
x_52 = lean_box(0);
lean_inc_ref(x_47);
x_53 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_53, 0, x_47);
lean_ctor_set(x_53, 1, x_52);
x_3 = x_53;
x_4 = x_47;
goto block_9;
}
else
{
uint32_t x_54; uint32_t x_55; uint8_t x_56; 
x_54 = 41;
x_55 = lean_string_utf8_get_fast(x_48, x_49);
x_56 = lean_uint32_dec_eq(x_55, x_54);
if (x_56 == 0)
{
lean_object* x_57; lean_object* x_58; 
lean_dec(x_49);
lean_dec_ref(x_48);
lean_dec(x_46);
x_57 = l_Parser_factor___closed__7;
lean_inc_ref(x_47);
x_58 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_58, 0, x_47);
lean_ctor_set(x_58, 1, x_57);
x_3 = x_58;
x_4 = x_47;
goto block_9;
}
else
{
lean_object* x_59; lean_object* x_60; lean_object* x_61; lean_object* x_62; 
lean_dec_ref(x_2);
if (lean_is_exclusive(x_47)) {
 lean_ctor_release(x_47, 0);
 lean_ctor_release(x_47, 1);
 x_59 = x_47;
} else {
 lean_dec_ref(x_47);
 x_59 = lean_box(0);
}
x_60 = lean_string_utf8_next_fast(x_48, x_49);
lean_dec(x_49);
if (lean_is_scalar(x_59)) {
 x_61 = lean_alloc_ctor(0, 2, 0);
} else {
 x_61 = x_59;
}
lean_ctor_set(x_61, 0, x_48);
lean_ctor_set(x_61, 1, x_60);
x_62 = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(x_62, 0, x_61);
lean_ctor_set(x_62, 1, x_46);
return x_62;
}
}
}
}
else
{
if (lean_obj_tag(x_25) == 0)
{
lean_dec_ref(x_2);
return x_25;
}
else
{
lean_object* x_63; 
x_63 = lean_ctor_get(x_25, 0);
lean_inc(x_63);
x_3 = x_25;
x_4 = x_63;
goto block_9;
}
}
}
}
block_9:
{
lean_object* x_5; lean_object* x_6; uint8_t x_7; 
x_5 = lean_ctor_get(x_2, 1);
lean_inc(x_5);
lean_dec_ref(x_2);
x_6 = lean_ctor_get(x_4, 1);
x_7 = lean_nat_dec_eq(x_5, x_6);
lean_dec(x_5);
if (x_7 == 0)
{
lean_dec_ref(x_4);
return x_3;
}
else
{
lean_object* x_8; 
lean_dec_ref(x_3);
x_8 = l_Parser_integer(x_4);
return x_8;
}
}
block_13:
{
lean_object* x_12; 
lean_inc_ref(x_10);
x_12 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_12, 0, x_10);
lean_ctor_set(x_12, 1, x_11);
x_3 = x_12;
x_4 = x_10;
goto block_9;
}
}
}
static lean_object* _init_l_Parser_parseExpr___closed__0() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l_Parser_expr), 1, 0);
return x_1;
}
}
LEAN_EXPORT lean_object* l_Parser_parseExpr(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; 
x_2 = l_Parser_parseExpr___closed__0;
x_3 = l_Std_Internal_Parsec_String_Parser_run___redArg(x_2, x_1);
if (lean_obj_tag(x_3) == 0)
{
lean_object* x_4; 
lean_dec_ref(x_3);
x_4 = lean_box(0);
return x_4;
}
else
{
uint8_t x_5; 
x_5 = !lean_is_exclusive(x_3);
if (x_5 == 0)
{
return x_3;
}
else
{
lean_object* x_6; lean_object* x_7; 
x_6 = lean_ctor_get(x_3, 0);
lean_inc(x_6);
lean_dec(x_3);
x_7 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_7, 0, x_6);
return x_7;
}
}
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
lean_object* initialize_Std_Internal_Parsec_String(uint8_t builtin, lean_object*);
lean_object* initialize_LeanSpl_Absyn(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_LeanSpl_Parser(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Std_Internal_Parsec_String(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_LeanSpl_Absyn(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0 = _init_l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0();
lean_mark_persistent(l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__0);
l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1 = _init_l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1();
lean_mark_persistent(l_Std_Internal_Parsec_manyCharsCore___at___Parser_integer_spec__0___closed__1);
l_Parser_integer___closed__0 = _init_l_Parser_integer___closed__0();
lean_mark_persistent(l_Parser_integer___closed__0);
l_Parser_integer___closed__1 = _init_l_Parser_integer___closed__1();
lean_mark_persistent(l_Parser_integer___closed__1);
l_Parser_integer___closed__2 = _init_l_Parser_integer___closed__2();
lean_mark_persistent(l_Parser_integer___closed__2);
l_Parser_integer___closed__3 = _init_l_Parser_integer___closed__3();
lean_mark_persistent(l_Parser_integer___closed__3);
l_Parser_integer___closed__4 = _init_l_Parser_integer___closed__4();
lean_mark_persistent(l_Parser_integer___closed__4);
l_Parser_integer___closed__5 = _init_l_Parser_integer___closed__5();
lean_mark_persistent(l_Parser_integer___closed__5);
l_Parser_integer___closed__6 = _init_l_Parser_integer___closed__6();
lean_mark_persistent(l_Parser_integer___closed__6);
l_Parser_expr_x27___closed__0 = _init_l_Parser_expr_x27___closed__0();
lean_mark_persistent(l_Parser_expr_x27___closed__0);
l_Parser_expr_x27___closed__1 = _init_l_Parser_expr_x27___closed__1();
lean_mark_persistent(l_Parser_expr_x27___closed__1);
l_Parser_expr_x27___closed__2 = _init_l_Parser_expr_x27___closed__2();
lean_mark_persistent(l_Parser_expr_x27___closed__2);
l_Parser_expr_x27___closed__3 = _init_l_Parser_expr_x27___closed__3();
lean_mark_persistent(l_Parser_expr_x27___closed__3);
l_Parser_term_x27___closed__0 = _init_l_Parser_term_x27___closed__0();
lean_mark_persistent(l_Parser_term_x27___closed__0);
l_Parser_term_x27___closed__1 = _init_l_Parser_term_x27___closed__1();
lean_mark_persistent(l_Parser_term_x27___closed__1);
l_Parser_term_x27___closed__2 = _init_l_Parser_term_x27___closed__2();
lean_mark_persistent(l_Parser_term_x27___closed__2);
l_Parser_term_x27___closed__3 = _init_l_Parser_term_x27___closed__3();
lean_mark_persistent(l_Parser_term_x27___closed__3);
l_Parser_term_x27___closed__4 = _init_l_Parser_term_x27___closed__4();
lean_mark_persistent(l_Parser_term_x27___closed__4);
l_Parser_term_x27___closed__5 = _init_l_Parser_term_x27___closed__5();
lean_mark_persistent(l_Parser_term_x27___closed__5);
l_Parser_term_x27___closed__6 = _init_l_Parser_term_x27___closed__6();
lean_mark_persistent(l_Parser_term_x27___closed__6);
l_Parser_term_x27___closed__7 = _init_l_Parser_term_x27___closed__7();
lean_mark_persistent(l_Parser_term_x27___closed__7);
l_Parser_factor___closed__0 = _init_l_Parser_factor___closed__0();
lean_mark_persistent(l_Parser_factor___closed__0);
l_Parser_factor___closed__1 = _init_l_Parser_factor___closed__1();
lean_mark_persistent(l_Parser_factor___closed__1);
l_Parser_factor___closed__2 = _init_l_Parser_factor___closed__2();
lean_mark_persistent(l_Parser_factor___closed__2);
l_Parser_factor___closed__3 = _init_l_Parser_factor___closed__3();
lean_mark_persistent(l_Parser_factor___closed__3);
l_Parser_factor___closed__4 = _init_l_Parser_factor___closed__4();
lean_mark_persistent(l_Parser_factor___closed__4);
l_Parser_factor___closed__5 = _init_l_Parser_factor___closed__5();
lean_mark_persistent(l_Parser_factor___closed__5);
l_Parser_factor___closed__6 = _init_l_Parser_factor___closed__6();
lean_mark_persistent(l_Parser_factor___closed__6);
l_Parser_factor___closed__7 = _init_l_Parser_factor___closed__7();
lean_mark_persistent(l_Parser_factor___closed__7);
l_Parser_parseExpr___closed__0 = _init_l_Parser_parseExpr___closed__0();
lean_mark_persistent(l_Parser_parseExpr___closed__0);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
