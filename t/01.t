use strict;
use Test::More;
use Test::Mojo;
use Mojo::DOM;

require 't/lite-01.pl';

my $attr_method = Mojo::DOM->can('attrs') ? 'attrs' : 'attr';

my $t = Test::Mojo->new();
$t->get_ok('/');
my $dom = $t->tx->res->dom;
like($dom->html->head->link->$attr_method('href'), qr!app\.css\?nc=\d+!, "relative stylesheet url");
like($dom->html->body->img->$attr_method('src'), qr!/t\.gif\?nc=\d+!, "absolute image url");
is($dom->html->head->script->$attr_method('src'), '/foo.js', "non-existent js");

$t->get_ok('/p1');
$dom = $t->tx->res->dom;
like(my $src = $dom->html->head->script->$attr_method('src'), qr!/app.js\?v=12&nc=\d+!, "url with query param");
is($dom->html->head->link->$attr_method('href'), 'mem.css', "url to inline css");
is($dom->html->body->img->$attr_method('src'), '../lite-01.pl', "url to the image outside public dir");
my $time = time() + 1000;

utime $time, $time, 't/public/app.js';
$t->get_ok('/p1');
$dom = $t->tx->res->dom;
is($dom->html->head->script->$attr_method('src'), $src, "mtime cached");

$t->get_ok('/p1/p2');
$dom = $t->tx->res->dom;
like($dom->html->head->link->[0]->$attr_method('href'), qr!\./style\.css\?nc=\d+!, "relative url from sub path");
is($dom->html->head->link->[1]->$attr_method('href'), 'app.css', "relative url from sub path on non exsitent file, but cached from other request");

done_testing;
