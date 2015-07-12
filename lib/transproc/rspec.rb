# encoding: utf-8

# ==============================================================================
# Examples for testing transproc functions
# ==============================================================================

shared_context :call_transproc do
  let!(:__initial__) { input.dup rescue input      }
  let!(:__fn__)      { described_class[*arguments] }
  subject { __fn__[input] }
end

shared_examples :transforming_data do
  include_context :call_transproc

  it '[returns the expected output]' do
    expect(subject).to eql(output), <<-REPORT.gsub(/.+\|/, "")
      |
      |fn = #{described_class}#{Array[*arguments]}
      |
      |fn[#{input}]
      |
      |  expected: #{output}
      |       got: #{subject}
    REPORT
  end
end

shared_examples :transforming_immutable_data do
  include_context :call_transproc

  it_behaves_like :transforming_data

  it '[keeps input unchanged]' do
    expect { subject }
      .not_to change { input }, <<-REPORT.gsub(/.+\|/, "")
        |
        |fn = #{described_class}#{Array[*arguments]}
        |
        |expected: not to change #{__initial__}
        |     got: changed it to #{input}
      REPORT
  end
end

shared_examples :mutating_input_data do
  include_context :call_transproc

  it_behaves_like :transforming_data

  it '[changes input]' do
    expect { subject }
      .to change { input }
      .to(output), <<-REPORT.gsub(/.+\|/, "")
        |
        |fn = #{described_class}#{Array[*arguments]}
        |
        |fn[#{input}]
        |
        |expected: to change input to #{output}
        |     got: #{input}
      REPORT
  end
end
