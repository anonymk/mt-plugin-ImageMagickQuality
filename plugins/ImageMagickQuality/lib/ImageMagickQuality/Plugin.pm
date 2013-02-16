package ImageMagickQuality::Plugin;

use strict;
use warnings;
use MT::Image::ImageMagick;

sub init_app {
	no strict 'refs';
	no warnings 'redefine';
	*MT::Image::ImageMagick::scale = \&_scale;
}

sub _scale {
	my $image = shift;
	my ($w, $h) = $image->get_dimensions(@_);
	my $magick = $image->{magick};
	my $blob;
	eval {
		my $err = $magick->can('Resize') ? $magick->Resize(width => $w, height => $h) : $magick->Scale(width => $w, height => $h);
		return $image->error(
			MT->translate("Scaling to [_1]x[_2] failed: [_3]", $w, $h, $err)
		) if $err;
		$magick->Profile("*") if $magick->can('Profile');
		($image->{width}, $image->{height}) = ($w, $h);
		my $quality = MT->config('ImageMagickQuality');
		if(defined $quality) {
			$magick->Set(quality => $quality);
		}
		$blob = $magick->ImageToBlob;
	};
	return $image->error(
		MT->translate("Scaling to [_1]x[_2] failed: [_3]", $w, $h, $@)
	) if $@;
	wantarray ? ($blob, $w, $h) : $blob;
}

1;
