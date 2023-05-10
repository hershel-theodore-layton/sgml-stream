/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HH\Lib\{C, Str, Vec};
use type Facebook\HHAST\{
  BackslashToken,
  BaseMigration,
  ClassishDeclaration,
  CommaToken,
  FunctionDeclarationHeader,
  INameishNode,
  ListItem,
  NameToken,
  NodeList,
  ParameterDeclaration,
  QualifiedName,
  Script,
  SemicolonToken,
  SimpleTypeSpecifier,
  TraitUse,
  UseToken,
  VariableToken,
  WhiteSpace,
};

final class UserElementMigration extends BaseMigration {
  const keyset<string> USER_ELEMENT_CLASS_NAMES = keyset[
    'AsynchronousUserElement',
    'AsynchronousUserElementWithWritableFlow',
    'DissolvableUserElement',
    'SimpleUserElement',
    'SimpleUserElementWithWritableFlow',
  ];

  const keyset<string> COMPOSE_METHOD_NAMES = keyset[
    'compose',
    'composeAsync',
  ];

  const keyset<string> NEEDS_IGNORE_SUCCESSOR_FLOW = keyset[
    'AsynchronousUserElement',
    'AsynchronousUserElementWithWritableFlow',
    'SimpleUserElement',
    'SimpleUserElementWithWritableFlow',
  ];

  <<__Override>>
  public function migrateFile(string $path, Script $ast): Script {
    $code_as_string = $ast->getCode();
    if (!Str\contains($code_as_string, 'SGMLStream')) {
      return $ast;
    }

    $namespace_scopes = $ast->getNamespaces();
    if (C\count($namespace_scopes) !== 1) {
      \error_log('Namespace blocks not supported. Failed to migrate: '.$path);
      return $ast;
    }
    list($uses_sgml_stream, $uses_sgml_stream_interfaces) =
      static::getUsedNamespaces($namespace_scopes);

    return static::migrateImpl(
      $ast,
      $uses_sgml_stream_interfaces,
      $uses_sgml_stream,
    );
  }

  private static function migrateImpl(
    Script $ast,
    bool $uses_sgml_stream_interfaces,
    bool $uses_sgml_stream,
  ): Script {
    foreach ($ast->traverse() as $node) {
      if (
        $node is ClassishDeclaration &&
        $node->hasExtendsKeyword() &&
        C\any(
          static::NEEDS_IGNORE_SUCCESSOR_FLOW,
          $cls ==> Str\contains($node->getExtendsListx()->getCode(), $cls),
        )
      ) {
        $ast = $ast->replace(
          $node,
          static::addIgnoreSuccessorFlow($node, $uses_sgml_stream),
        );
      }

      if (
        $node is NameToken &&
        C\contains_key(static::USER_ELEMENT_CLASS_NAMES, $node->getText())
      ) {
        $ast = $ast->replace(
          $node,
          $node->withText(
            Str\replace($node->getText(), 'UserElement', 'Element'),
          ),
        );
      }

      if (
        $node is FunctionDeclarationHeader &&
        C\contains_key(
          static::COMPOSE_METHOD_NAMES,
          $node->getName()->getText(),
        )
      ) {
        $ast = $ast->replace(
          $node,
          static::upgradeComposeMethod($node, $uses_sgml_stream_interfaces),
        );
      }
    }

    return $ast;
  }

  private static function getUsedNamespaces(
    vec<Script::TNamespaceScope> $namespace_scopes,
  ): (bool, bool) {
    $namespace_scope = $namespace_scopes[0];
    $uses = $namespace_scope['uses'];

    $uses_sgml_stream = idx($uses['namespaces'], 'SGMLStream')
      |> Shapes::idx($$, 'name') === 'HTL\\SGMLStream';
    $uses_sgml_stream_interfaces =
      idx($uses['namespaces'], 'SGMLStreamInterfaces')
      |> Shapes::idx($$, 'name') === 'HTL\\SGMLStreamInterfaces';
    return tuple($uses_sgml_stream, $uses_sgml_stream_interfaces);
  }

  private static function addIgnoreSuccessorFlow(
    ClassishDeclaration $class,
    bool $uses_sgml_stream,
  ): ClassishDeclaration {
    $ignore_successor_flow_class = new SimpleTypeSpecifier(
      $uses_sgml_stream
        ? static::toName('SGMLStream\\IgnoreSuccessorFlow')
        : static::toName('\\HTL\\SGMLStream\\IgnoreSuccessorFlow'),
    );

    return $class->withBody(
      $class->getBody()->withElements(
        NodeList::concat(
          new NodeList(vec[new TraitUse(
            new UseToken(
              new NodeList(vec[new WhiteSpace('  ')]),
              new NodeList(vec[new WhiteSpace(' ')]),
            ),
            new NodeList(vec[new ListItem($ignore_successor_flow_class, null)]),
            new SemicolonToken(null, new NodeList(vec[new WhiteSpace("\n")])),
          )]),
          $class->getBody()->getElementsx(),
        ),
      ),
    );
  }

  private static function upgradeComposeMethod(
    FunctionDeclarationHeader $decl_header,
    bool $uses_sgml_stream_interfaces,
  ): FunctionDeclarationHeader {
    $name = $decl_header->getName() as NameToken;
    $parameter_list = $decl_header->getParameterList() ?? new NodeList(vec[]);
    $last_param = $parameter_list->getChildren() |> C\last($$);

    $init_flow_type = new SimpleTypeSpecifier(
      $uses_sgml_stream_interfaces
        ? static::toName('SGMLStreamInterfaces\\Flow ')
        : static::toName('Flow '),
    );

    if ($last_param is nonnull) {
      $parameter_list = $parameter_list->replaceChild(
        $last_param,
        $last_param->withSeparator(
          new CommaToken(null, new NodeList(vec[new WhiteSpace(' ')])),
        ),
      );
    }

    $init_flow_param = new ParameterDeclaration(
      null,
      null,
      null,
      null,
      $init_flow_type,
      new VariableToken(null, null, '$_init_flow'),
      null,
    );
    return $decl_header
      ->withName(
        $name->withText(Str\replace($name->getText(), 'compose', 'render')),
      )
      ->withParameterList(
        NodeList::concat(
          $parameter_list,
          new NodeList(vec[new ListItem($init_flow_param, null)]),
        ),
      );
  }

  private static function toName(string $text): INameishNode {
    if (!Str\contains($text, '\\')) {
      $name_token = static::nameTokenFromText($text);
      invariant(
        $name_token is nonnull,
        'Can not create a name from a whitespace string',
      );
    }

    $parts = Str\split($text, '\\');
    $last = C\count($parts) - 1;

    return Vec\map_with_key(
      $parts,
      ($i, $part) ==> new ListItem(
        static::nameTokenFromText($part),
        $i === $last ? null : new BackslashToken(null, null),
      ),
    )
      |> new NodeList($$)
      |> new QualifiedName($$);
  }

  private static function nameTokenFromText(string $text): ?NameToken {
    $trimmed_text = Str\trim_left($text);
    $leading =
      Str\slice($text, 0, Str\length($text) - Str\length($trimmed_text));
    $text = $trimmed_text;
    $trimmed_text = Str\trim_right($text);
    $trailing = Str\slice($text, Str\length($trimmed_text));

    return $trimmed_text === ''
      ? null
      : new NameToken(
          $leading === '' ? null : new NodeList(vec[new WhiteSpace($leading)]),
          $trailing === ''
            ? null
            : new NodeList(vec[new WhiteSpace($trailing)]),
          $trimmed_text,
        );
  }
}
