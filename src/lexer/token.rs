//! Token kinds produced by the lexer.
//!
//! Kite v0.1.1 uses Python-style indentation to delimit blocks, so the
//! token stream includes structural `Newline`/`Indent`/`Dedent` tokens in
//! addition to the usual lexical categories.

use crate::diagnostics::Span;
use std::fmt;

#[derive(Debug, Clone, PartialEq)]
pub enum TokenKind {
    // Literals
    IntLiteral(i64),
    FloatLiteral(f64),
    StringLiteral(String),

    // Identifiers & keywords
    Identifier(String),
    Make,   // fn declaration
    Extern, // extern function declaration (C FFI)
    Return,
    If,
    Orif, // else-if
    Else,
    Until,   // loop while condition is false
    Infinit, // infinite loop
    For,
    To,
    In,
    Break,
    Continue,
    Try,
    Failed,
    Finally,
    Use,
    From,
    Import,
    Type, // struct declaration
    Enum, // enum declaration
    Thread,
    Async,
    Await,
    And,
    Or,
    Not,
    True,
    False,

    // Type keywords
    KwInt,
    KwFloat,
    KwBool,
    KwString,

    // Punctuation
    LParen,   // (
    RParen,   // )
    LBracket, // [
    RBracket, // ]
    LBrace,   // { (dict literals only)
    RBrace,   // }
    Comma,    // ,
    Colon,    // :
    Dot,      // .
    Arrow,    // -> (optional explicit return type)

    // Operators
    Plus,
    Minus,
    Star,
    Slash,
    Percent,
    EqEq,
    NotEq,
    Lt,
    Gt,
    LtEq,
    GtEq,
    Eq,

    // Structural
    Newline,
    Indent,
    Dedent,
    Eof,
}

impl fmt::Display for TokenKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use TokenKind::*;
        match self {
            IntLiteral(v) => write!(f, "integer literal `{v}`"),
            FloatLiteral(v) => write!(f, "float literal `{v}`"),
            StringLiteral(v) => write!(f, "string literal \"{v}\""),
            Identifier(name) => write!(f, "identifier `{name}`"),
            Make => write!(f, "`make`"),
            Extern => write!(f, "`extern`"),
            Return => write!(f, "`return`"),
            If => write!(f, "`if`"),
            Orif => write!(f, "`orif`"),
            Else => write!(f, "`else`"),
            Until => write!(f, "`until`"),
            Infinit => write!(f, "`infinit`"),
            For => write!(f, "`for`"),
            To => write!(f, "`to`"),
            In => write!(f, "`in`"),
            Break => write!(f, "`break`"),
            Continue => write!(f, "`continue`"),
            Try => write!(f, "`try`"),
            Failed => write!(f, "`failed`"),
            Finally => write!(f, "`finally`"),
            Use => write!(f, "`use`"),
            From => write!(f, "`from`"),
            Import => write!(f, "`import`"),
            Type => write!(f, "`type`"),
            Enum => write!(f, "`enum`"),
            Thread => write!(f, "`thread`"),
            Async => write!(f, "`async`"),
            Await => write!(f, "`await`"),
            And => write!(f, "`and`"),
            Or => write!(f, "`or`"),
            Not => write!(f, "`not`"),
            True => write!(f, "`true`"),
            False => write!(f, "`false`"),
            KwInt => write!(f, "`int`"),
            KwFloat => write!(f, "`float`"),
            KwBool => write!(f, "`bool`"),
            KwString => write!(f, "`string`"),
            LParen => write!(f, "`(`"),
            RParen => write!(f, "`)`"),
            LBracket => write!(f, "`[`"),
            RBracket => write!(f, "`]`"),
            LBrace => write!(f, "`{{`"),
            RBrace => write!(f, "`}}`"),
            Comma => write!(f, "`,`"),
            Colon => write!(f, "`:`"),
            Dot => write!(f, "`.`"),
            Arrow => write!(f, "`->`"),
            Plus => write!(f, "`+`"),
            Minus => write!(f, "`-`"),
            Star => write!(f, "`*`"),
            Slash => write!(f, "`/`"),
            Percent => write!(f, "`%`"),
            EqEq => write!(f, "`==`"),
            NotEq => write!(f, "`!=`"),
            Lt => write!(f, "`<`"),
            Gt => write!(f, "`>`"),
            LtEq => write!(f, "`<=`"),
            GtEq => write!(f, "`>=`"),
            Eq => write!(f, "`=`"),
            Newline => write!(f, "end of line"),
            Indent => write!(f, "indented block"),
            Dedent => write!(f, "end of indented block"),
            Eof => write!(f, "end of file"),
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Token {
    pub kind: TokenKind,
    pub span: Span,
}

impl Token {
    pub fn new(kind: TokenKind, span: Span) -> Self {
        Self { kind, span }
    }
}

/// Maps identifier text to a keyword token kind, if it is one.
pub fn lookup_keyword(ident: &str) -> Option<TokenKind> {
    use TokenKind::*;
    Some(match ident {
        "make" => Make,
        "extern" => Extern,
        "return" => Return,
        "if" => If,
        "orif" => Orif,
        "else" => Else,
        "until" => Until,
        "infinit" => Infinit,
        "for" => For,
        "to" => To,
        "in" => In,
        "break" => Break,
        "continue" => Continue,
        "try" => Try,
        "failed" => Failed,
        "finally" => Finally,
        "use" => Use,
        "from" => From,
        "import" => Import,
        "type" => Type,
        "enum" => Enum,
        "thread" => Thread,
        "async" => Async,
        "await" => Await,
        "and" => And,
        "or" => Or,
        "not" => Not,
        "true" => True,
        "false" => False,
        "int" => KwInt,
        "float" => KwFloat,
        "bool" => KwBool,
        "string" => KwString,
        _ => return None,
    })
}
