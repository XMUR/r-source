#-*- mode: perl; perl-indent-level: 4; cperl-indent-level: 4 -*-
#
# process bundle files.
# args  bundle srcdir destdir

($bundle, $srcdir, $destdir) = @ARGV;

open bundledesc, "< $srcdir/$bundle/DESCRIPTION" || die "no DESCRIPTION found";
while(<bundledesc>) {
    if(/^Contains:/) {
	s/^Contains://; s/,/ /;
	@pkgs = split " ";
    }
}
close bundledesc;

foreach $pkg (@pkgs) {
    print "\n---- Building package $pkg from bundle $bundle -----\n";
    open pkgdesc, "> $srcdir/$bundle/$pkg/DESCRIPTION" 
	|| die "cannot write $pkg/DESCRIPTION";
    if (open pkgdescin, "< $srcdir/$bundle/$pkg/DESCRIPTION.in") {
	while(<pkgdescin>) { print pkgdesc $_; }
	close pkgdescin;
    } else {
	print "no DESCRIPTION.in found for package $pkg";
	print pkgdesc "Package: $pkg\n";
    }
    open bundledesc, "< $srcdir/$bundle/DESCRIPTION" 
	|| die "no DESCRIPTION found";
    while(<bundledesc>) {
	if(!/^Contains:/) {print pkgdesc $_;}
    }
    close bundledesc;
    close pkgdesc;
    $cmd = "make PKGDIR=$srcdir/$bundle RLIBS=$destdir pkg-$pkg";
#    print "$cmd\n";
    system($cmd);
}
