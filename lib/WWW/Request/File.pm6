class WWW::Request::File;

## Represents an uploaded file.

has $.formname;            ## The HTML form name.
has $.filename;            ## The filename for the upload.
has $.content-type is rw;  ## The plain value for Content-Type with no options.
has @.headers is rw;       ## The MIME headers.
has $.temppath is rw;      ## Where we've stored the actual file.
has $!output is rw;        ## Our IO object for output.

constant $CRLF = "\x0D\x0A";

## We take the form name, and filename as our parameters.
method new ($formname!, $filename!) {
  my $temppath = "/tmp/wrf-{time}.$*PID";
  my $output   = open($temppath, :w);
  return self.bless(*, :$formname, :$filename, :$temppath, :$output);
}

## Delete the file.
method delete {
  if $.temppath && $.temppath.IO ~~ :f {
    unlink($.temppath);
  }
}

## Print to the file, with no newlines.
method print (*@lines) {
  if $!output {
    $!output!print(|@lines);
  }
}

## Use "say" on the file.
method say (*@lines) {
  if $!output {
    $!output!say(|@lines);
  }
}

## Print a string to the file, but with CRLF at the end.
method out ($string) {
  self.print($string~$CRLF);
}

## Close, close the output IO object, and return this.
method close {
  if $!output {
    $!output.close; ## Close the IO.
    $!output = Nil; ## Kill the IO.
  }
  return self;
}

## Return an open file for reading.
method get {
  if $.temppath && $.temppath.IO ~~ :f {
    return open($.temppath, :r);
  }
  return; ## Sorry, nothing to return.
}

## Return the lines.
method lines {
  if $.temppath && $.tempppath.IO ~~ :f {
    return lines($.temppath);
  }
  return;
}

## Return the content.
method slurp {
  if $.temppath && $.temppath.IO ~~ :f {
    return slurp($.temppath);
  }
  return;
}

## Get a header if it exists.
## By default returns the text value from the first matching header.
## If you want all matching headers, add the :multiple flag.
## If you want options in addition to the text value, add the :opts flag.
## See WWW::Request::Multipart::parse-mime-header() for the storage format.
method header ($name, Bool :$multiple, Bool :$opts) {
  my @results;
  for @.headers -> $header {
    ## Headers are stored as a Pair.
    if $header.key.lc eq $name { 
      my $result = $header.value;
      if $multiple {
        if $opts {
          @results.push($result);
        }
        else {
          @results.push($result[0]);
        }
      }
      else { ## A single value.
        if $opts { return $result; }
        else { return $result[0]; }
      }
    }
  }
  if $multiple {
    return @results;
  }
  else {
    return Nil;
  }
}

